//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (map)
+ (RWPromise *) map:(NSArray *) array :(RWMapFuncBlock) mapFunc
{
    NSMutableArray<RWPromise*>* promises = @[].mutableCopy;
    
    [array enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL* stop) {
        [promises addObject:mapFunc(obj)];
    }];
    return [RWPromise all:promises];
}
@end
