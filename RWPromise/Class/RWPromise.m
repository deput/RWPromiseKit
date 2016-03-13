//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise.h"

#define STATE_PROTECT if (sSelf.state != RWPromiseStatePending) return;

@interface RWPromise ()

@property(nonatomic) id value;
@property(nonatomic) NSError *error;
@property(atomic, assign) RWPromiseState state;

@property(nonatomic, strong) id strongSelf;

@property(nonatomic, strong) RWPromise *depPromise;

@property(nonatomic, copy) ResolveHandler resolveBlock;

@property(nonatomic, copy) RejectHandler rejectBlock;

@property(nonatomic, copy) RWPromiseBlock promiseBlock;

@property(nonatomic, copy) RejectHandler catchBlock;

@property(nonatomic, copy) ResolveHandler thenBlock;

@property(nonatomic, copy) NSString *identifier;

- (instancetype)init:(RWPromiseBlock)initBlock;
@end

@interface RWAllPromise:RWPromise
- (instancetype)initWithAllPromises:(NSArray<RWPromise*> *)promises;
@property(nonatomic, strong) NSMutableSet<RWPromise*> * promises;
@end

@interface RWRacePromise:RWPromise
- (instancetype)initWithRacePromises:(NSArray<RWPromise*> *)promises;
@property(nonatomic, strong) NSMutableSet<RWPromise*> * promises;
@end


@implementation RWPromise {

}

+ (RWPromise *)timeout:(NSTimeInterval)timeInSec {
    return [self promise:^(ResolveHandler resolve, RejectHandler reject) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (timeInSec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            resolve(@"Timeout");
        });
    }];
}

+ (RWPromise *)promise:(RWPromiseBlock)block {
    return [[RWPromise alloc] init:block];
}

+ (RWPromise *)all:(NSArray<RWPromise *> *)promises {
    return [[RWAllPromise alloc] initWithAllPromises:promises];
}

+ (RWPromise *)race:(NSArray<RWPromise *> *)promises {
    return [[RWRacePromise alloc] initWithRacePromises:promises];
}

- (instancetype)init:(RWPromiseBlock)initBlock {
    self = [super init];

    static int i = 0;
    i++;
    self.identifier = [@(i) stringValue];

    if (self) {
        self.state = RWPromiseStatePending;
        [self keepAlive];

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
                    //[sSelf losingControl];
                }
            } else {
                sSelf.value = value;
                sSelf.state = RWPromiseStateResolved;
                [sSelf losingControl];
            }
        };

        self.rejectBlock = ^(NSError *error) {
            __strong RWPromise *sSelf = wSelf;
            STATE_PROTECT;
            [sSelf losingControl];
            sSelf.error = error;
            NSLog(@"%@-%@", sSelf, [error description]);
            sSelf.state = RWPromiseStateRejected;
        };

        self.promiseBlock = initBlock;
    }

    [self run];
    return self;
}


- (void)keepAlive {
    self.strongSelf = self;
}

- (void)losingControl {
    self.strongSelf = nil;
}

- (void)dealloc {
    //
    NSLog(@"dealloc");
    self.state = self.state;

    if (self.state == RWPromiseStatePending && self.depPromise) {
        if (self.depPromise.state == RWPromiseStateRejected) {
            if (self.catchBlock) {
                self.catchBlock(self.depPromise.error);
                self.resolveBlock(nil);
            } else {
                self.rejectBlock(self.depPromise.error);
            }


        } else if (self.depPromise.state == RWPromiseStateResolved) {
            //self.resolveBlock(self.depPromise.value);
            if (self.thenBlock) {
                if (self.thenBlock) {
                    self.thenBlock(self.depPromise.value);
                }
                self.resolveBlock(self.depPromise.value);
            }
        }

        //self.depPromise.state = self.depPromise.state;


    }
    self.depPromise = nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        RWPromiseState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (newState == RWPromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            if (self.catchBlock) {
                self.catchBlock([(RWPromise *) object error]);
                self.resolveBlock(nil);

            } else {
                self.rejectBlock([(RWPromise *) object error]);
            }

        } else if (newState == RWPromiseStateResolved) {
            [object removeObserver:self forKeyPath:@"state"];
            if (self.thenBlock) {
                self.thenBlock([(RWPromise *) object value]);
            }
            self.resolveBlock([(RWPromise *) object value]);
        }
    }
}

- (void)run {
    if (self.promiseBlock) {
        self.promiseBlock(self.resolveBlock, self.rejectBlock);
    }
}

- (__autoreleasing RWPromise *(^)(RWRunBlock))then {
    __weak RWPromise *wSelf = self;
    return ^__autoreleasing RWPromise *(RWRunBlock thenBlock) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.thenBlock = thenBlock;
        return newPromise;
    };
}

- (__autoreleasing RWPromise *(^)(RWErrorBlock))catch {
    __weak RWPromise *wSelf = self;
    return ^__autoreleasing RWPromise *(RWErrorBlock catchBlock) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.catchBlock = catchBlock;
        return newPromise;
    };
}

@end



@implementation RWAllPromise
{
    NSMutableArray *_values;
}

- (instancetype)initWithAllPromises:(NSArray<RWPromise*> *)promises{
    self = [super init];
    _values = @[].mutableCopy;
    self.promises = [NSMutableSet set];
    self.state = RWPromiseStatePending;
    [self keepAlive];

    [promises enumerateObjectsUsingBlock:^(RWPromise *promise, NSUInteger idx, BOOL *stop) {
        [promise addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        if (promise.state == RWPromiseStatePending){
            [self.promises addObject:promise];
        }else{

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
                //[sSelf losingControl];
            }
        } else {
            sSelf.value = value;
            sSelf.state = RWPromiseStateResolved;
            [sSelf losingControl];
        }
    };

    self.rejectBlock = ^(NSError *error) {
        __strong RWPromise *sSelf = wSelf;
        STATE_PROTECT;
        [sSelf losingControl];
        sSelf.error = error;
        NSLog(@"%@-%@", sSelf, [error description]);
        sSelf.state = RWPromiseStateRejected;
    };

    //self.promiseBlock = initBlock;

    //[self run];
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

        if (self.promises.count == 0){
            self.resolveBlock(_values);
        }
    }
}

@end

@implementation RWRacePromise
{
    //NSMutableArray *_values;
}

- (instancetype)initWithRacePromises:(NSArray<RWPromise*> *)promises{
    self = [super init];
    self.promises = [NSMutableSet set];
    self.state = RWPromiseStatePending;
    [self keepAlive];

    [promises enumerateObjectsUsingBlock:^(RWPromise *promise, NSUInteger idx, BOOL *stop) {
        [promise addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:nil];
        if (promise.state == RWPromiseStatePending){
            [self.promises addObject:promise];
        }else{

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
                //[sSelf losingControl];
            }
        } else {
            sSelf.value = value;
            sSelf.state = RWPromiseStateResolved;
            [sSelf losingControl];
        }
    };

    self.rejectBlock = ^(NSError *error) {
        __strong RWPromise *sSelf = wSelf;
        STATE_PROTECT;
        [sSelf losingControl];
        sSelf.error = error;
        NSLog(@"%@-%@", sSelf, [error description]);
        sSelf.state = RWPromiseStateRejected;
    };

    //self.promiseBlock = initBlock;

    //[self run];
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

        if (self.promises.count == 0){
            self.rejectBlock([NSError errorWithDomain:@"race" code:2 userInfo:@{}]);
        }
    }
}

@end

__attribute__((constructor)) static void func() {

    @autoreleasepool {
        RWPromise *p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            NSLog(@"promize");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                resolve(@"Hello from 1");
                //reject([NSError errorWithDomain:@"RWPromise" code:1 userInfo:@{}]);
            });
        }];

        p1.then(^(id value) {
                    NSLog(@"then 1 - %@", value);
                    //return nil;
                })
                .then(^(id value) {
                    NSLog(@"and then 2 - %@", value);
                })
                .catch(^(NSError *error) {

                    NSLog(@"%@", @"Catch ya 1!");
                });
//        .then(^(id value) {
//            NSLog(@"and then 3 - %@", value);
//        });


//        p1.then(^(id value) {
//            NSLog(@"hey then - %@", value);
//            //return nil;
//        })

        NSArray * ps = @[[RWPromise timeout:1],[RWPromise timeout:3],p1];
        [RWPromise race:ps].then(^(id value){
            NSLog(@"All!");
        })
        .catch(^(NSError *e){
            NSLog(e);
        });
        NSLog(@"Hi");
    }


}