//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RWPromise.h"


@protocol RWThenable<NSObject>

@property (nonatomic) RWPromiseBlock then;
@end