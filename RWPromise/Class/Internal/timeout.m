//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@class RWAllPromise;

@implementation RWPromise (timeout)
- (RWPromise *(^)(NSTimeInterval))timeout
{
    //__weak RWPromise *wSelf = self;
    return ^RWPromise *(NSTimeInterval timeInSec) {
        __weak RWPromise *newPromise = [RWPromise race:@[self,[RWPromise timer:timeInSec]]];
        return newPromise;
    };
}
@end