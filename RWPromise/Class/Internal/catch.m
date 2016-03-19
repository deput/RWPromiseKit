//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (catch)
- (RWPromise *(^)(RWErrorBlock))catch {
    __weak RWPromise *wSelf = self;
    return ^RWPromise *(RWErrorBlock catchBlock) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.catchBlock = catchBlock;
        return newPromise;
    };
}
@end