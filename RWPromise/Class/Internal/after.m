//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@interface RWAfterPromise : RWPromise

@end

@implementation RWAfterPromise

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        RWPromiseState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (newState == RWPromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            self.rejectBlock([(RWPromise *) object error]);
        } else if (newState == RWPromiseStateResolved) {
            [object removeObserver:self forKeyPath:@"state"];
            self.value = [(RWPromise *) object value];
            @try {
                if (self.thenBlock) {
                    self.thenBlock([(RWPromise *) object value]);
                }
            } @catch (NSException *e) {
                self.rejectBlock([NSError errorWithDomain:@"RWPromise" code:1 userInfo:@{@"exception" : e}]);
            }
        }
    }
}
@end

@implementation RWPromise (after)

- (RWPromise *(^)(NSTimeInterval))after {
    __weak RWPromise *wSelf = self;
    return ^RWPromise *(NSTimeInterval timeInSec) {
        __weak RWPromise *newPromise = nil;
        newPromise = [[RWAfterPromise alloc] init:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.thenBlock = ^(id value) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (timeInSec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                newPromise.resolveBlock(newPromise.value);
            });
        };
        return newPromise;
    };
}
@end