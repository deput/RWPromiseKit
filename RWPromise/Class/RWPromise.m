//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise.h"
#import "RWPromise+Internal.h"
#import "RWThenable.h"

@implementation RWPromise

#pragma mark - Class Methods

+ (RWPromise *)timer:(NSTimeInterval)timeInSec {
    return [self promise:^(ResolveHandler resolve, RejectHandler reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (timeInSec * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            resolve(@{@"Timeout" : @(timeInSec)});
        });
    }];
}

+ (RWPromise *)promise:(RWPromiseBlock)block {
    return [[RWPromise alloc] init:block];
}

+ (RWPromise *)resolve:(id)value {
    if ([value isKindOfClass:[RWPromise class]]) {
        return value;
    } else if ([value conformsToProtocol:@protocol(RWThenable)]) {
        return [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            id <RWThenable> thenableObj = (id <RWThenable>) value;
            thenableObj.then(resolve, reject);
        }];
    } else {
        return [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(value);
        }];
    }
}

+ (RWPromise *)reject:(id)value {
    if ([value isKindOfClass:[RWPromise class]]) {
        return value;
    } else {
        return [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject([RWPromise errorWithValue:value]);
        }];
    }
}

#pragma mark - Instance Methods

- (instancetype)init:(RWPromiseBlock)initBlock {
    self = [super init];

    if (self) {
        [self privateInitialize];
        self.promiseBlock = initBlock;
    }

    [self run];
    return self;
}

- (void) privateInitialize
{
    if (self) {
#ifdef DEBUG
        static int i = 0;
        i++;
        self.identifier = [@(i) stringValue];
        NSLog(@"%@th promise", self.identifier);
#endif
        self.state = RWPromiseStatePending;
        [self keepAlive];
        
        __weak RWPromise *wSelf = self;
        self.resolveBlock = ^(id value) {
            __strong RWPromise *sSelf = wSelf;
            STATE_PROTECT;
            if ([value isKindOfClass:[RWPromise class]]) {
                if (((RWPromise *) value).state == RWPromiseStatePending) {
                    sSelf.depPromise = value;
                }
                [(RWPromise *) value addObserver:sSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            } else {
                sSelf.value = value;
                sSelf.state = RWPromiseStateResolved;
                [sSelf loseControl];
            }
        };
        
        self.rejectBlock = ^(NSError *error) {
            __strong RWPromise *sSelf = wSelf;
            STATE_PROTECT;
            [sSelf loseControl];
            sSelf.error = error;
#ifdef DEBUG
            NSLog(@"%@-%@", sSelf, [error description]);
#endif
            sSelf.state = RWPromiseStateRejected;
        };
    }
}

- (void)keepAlive {
    self.strongSelf = self;
}

- (void)loseControl {
    self.strongSelf = nil;
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%@th promise dealloc", self.identifier);
#endif
    self.state = self.state;
    self.depPromise = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    RWPromise *curPromise = (RWPromise *)object;
    if ([keyPath isEqualToString:@"state"]) {
        RWPromiseState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (newState == RWPromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            if (self.catchBlock) {
                self.catchBlock(curPromise.error);
                self.resolveBlock(nil);
            } else {
                self.rejectBlock(curPromise.error);
            }
        } else if (newState == RWPromiseStateResolved) {
            [object removeObserver:self forKeyPath:@"state"];
            @try {
                id value = nil;
                self.valueKeptForRetry = curPromise.value;
                if (self.thenBlock) {
                    value = self.thenBlock(curPromise.value);
                } else {
                    value = curPromise.value;
                }
                self.thenBlock = nil;
                self.resolveBlock(value);
            } @catch (NSException *e) {
                self.rejectBlock([RWPromise errorWithException:e]);
            }
        }
    }
}

- (void)run {
    if (self.promiseBlock) {
        @try {
            self.promiseBlock(self.resolveBlock, self.rejectBlock);
        } @catch (NSException *e) {
            self.rejectBlock([RWPromise errorWithException:e]);
        }
    }
}


@end

NSError *promiseErrorWithReason(NSString *reason) {
    return [RWPromise errorWithReason:reason];
}
