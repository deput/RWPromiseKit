//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (then)
- (__autoreleasing RWPromise *(^)(RWRunBlock))then {
    __weak RWPromise *wSelf = self;
    return ^RWPromise *(RWRunBlock thenBlock) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.thenBlock = thenBlock;
        return newPromise;
    };
}
@end