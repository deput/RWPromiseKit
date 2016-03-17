//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@interface RWAllPromise : RWPromise
- (instancetype)initWithAllPromises:(NSArray<RWPromise *> *)promises;

@property(nonatomic, strong) NSMutableSet<RWPromise *> *promises;
@end

@implementation RWAllPromise {
    NSMutableArray *_values;
}

- (instancetype)initWithAllPromises:(NSArray<RWPromise *> *)promises {
    self = [super init];
    _values = @[].mutableCopy;
    self.promises = [NSMutableSet set];
    self.state = RWPromiseStatePending;
    [self keepAlive];

    [promises enumerateObjectsUsingBlock:^(RWPromise *promise, NSUInteger idx, BOOL *stop) {
        [promise addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        if (promise.state == RWPromiseStatePending) {
            [self.promises addObject:promise];
        } else {

        }
    }];

    __weak RWPromise *wSelf = self;
    self.resolveBlock = ^(id value) {
        __strong RWPromise *sSelf = wSelf;
        STATE_PROTECT;
        if ([value isKindOfClass:[RWPromise class]]) {

            if (((RWPromise *) value).state == RWPromiseStatePending) {
                sSelf.depPromise = value;
                [value addObserver:sSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
            } else {
                //sSelf.depPromise = value;
                [value addObserver:sSelf forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
                //[sSelf loseControl];
            }
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
        NSLog(@"%@-%@", sSelf, [error description]);
        sSelf.state = RWPromiseStateRejected;
    };

    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        RWPromiseState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        [object removeObserver:self forKeyPath:@"state"];
        [self.promises removeObject:object];
        if (newState == RWPromiseStateRejected) {
            [self.promises enumerateObjectsUsingBlock:^(RWPromise *promise, BOOL *stop) {
                [promise removeObserver:self forKeyPath:@"state"];
            }];
            self.rejectBlock([(RWPromise *) object error]);
        } else if (newState == RWPromiseStateResolved) {
            //[object removeObserver:self forKeyPath:@"state"];
            [_values addObject:[(RWPromise *) object value]];
        }

        if (self.promises.count == 0) {
            self.resolveBlock(_values);
        }
    }
}

@end

@implementation RWPromise (all)

+ (RWPromise *)all:(NSArray<RWPromise *> *)promises {
    return [[RWAllPromise alloc] initWithAllPromises:promises];
}

@end