//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (finally)
- (void (^)(RWRunBlock))finally
{
    __weak RWPromise *wSelf = self;
    return ^(RWRunBlock runBlock) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.thenBlock = runBlock;
        newPromise.catchBlock = ^(NSError * error){
            runBlock(error);
        };
    };
}
@end

