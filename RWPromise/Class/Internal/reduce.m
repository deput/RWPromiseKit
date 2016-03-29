//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWPromise (reduce)
+ (RWPromise *) reduce:(NSArray *) array :(RWReduceFuncBlock) reduceFunc initialValue:(id)initialValue
{
    if (array.count == 0) {
        return nil;
    }
    __block RWPromise * p = reduceFunc(array[0],initialValue);
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0) {
            p = p.then(^id(id value){
                return reduceFunc(obj,value);
            });
        }
    }];

    return p.then(^id(id res){
        return res;
    });
}
@end