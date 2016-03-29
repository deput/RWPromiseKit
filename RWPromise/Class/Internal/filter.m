//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (filter)
+ (RWPromise *) filter:(NSArray *) array :(RWFilterFuncBlock) filterFunc
{
    NSMutableArray<RWPromise*>* promises = @[].mutableCopy;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        if (filterFunc(obj)) {
            [promises addObject:[RWPromise resolve:obj]];
        }
    }];
    return [RWPromise all:promises];
}
@end