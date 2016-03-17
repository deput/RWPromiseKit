//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (after)

- (RWPromise *(^)(NSTimeInterval))after {
    __weak RWPromise *wSelf = self;
    return ^RWPromise *(NSTimeInterval timeInSec) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];

        newPromise.thenBlock = ^(id value){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (timeInSec * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

            });
        };
        return newPromise;

    };
}
@end