//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (reduce)
+ (RWPromise *) reduce:(NSArray *) array :(RWReduceFuncBlock) reduceFunc initialValue:(id)initialValue
{
    NSMutableArray<RWPromise*>* promises = @[].mutableCopy;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [promises addObject:reduceFunc(obj,initialValue)];
    }];

    return [RWPromise all:promises].then(^id(NSArray* res){
        return res.lastObject;
    });
}
@end