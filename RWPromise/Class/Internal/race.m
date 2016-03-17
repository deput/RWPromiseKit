//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@interface RWRacePromise : RWPromise
- (instancetype)initWithRacePromises:(NSArray<RWPromise *> *)promises;

@property(nonatomic, strong) NSMutableSet<RWPromise *> *promises;
@end

@implementation RWRacePromise {
    //NSMutableArray *_values;
}

- (instancetype)initWithRacePromises:(NSArray<RWPromise *> *)promises {
    self = [super init];
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
        if (newState == RWPromiseStateResolved) {
            [self.promises enumerateObjectsUsingBlock:^(RWPromise *promise, BOOL *stop) {
                [promise removeObserver:self forKeyPath:@"state"];
            }];
            self.resolveBlock([(RWPromise *) object value]);
        } else if (newState == RWPromiseStateRejected) {

            //[object removeObserver:self forKeyPath:@"state"];
            //[_values addObject:[(RWPromise *) object value]];
        }

        if (self.promises.count == 0) {
            self.rejectBlock([NSError errorWithDomain:@"race" code:2 userInfo:@{}]);
        }
    }
}

@end

@implementation RWPromise (race)

+ (RWPromise *)race:(NSArray<RWPromise *> *)promises {
    return [[RWRacePromise alloc] initWithRacePromises:promises];
}

@end