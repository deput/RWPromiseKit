//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (finally)
- (void (^)(dispatch_block_t))finally
{
    __weak RWPromise *wSelf = self;
    return ^(dispatch_block_t runBlock) {
        __weak RWPromise *newPromise = nil;
        newPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(wSelf);
        }];
        newPromise.thenBlock = ^id(id value){
            runBlock();
            return nil;
        };
        newPromise.catchBlock = ^(NSError * error){
            runBlock();
        };
    };
}
@end

