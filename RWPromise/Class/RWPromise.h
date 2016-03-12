//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, RWPromiseState) {
    RWPromiseStatePending = 0,
    RWPromiseStateResolved = 1,
    RWPromiseStateRejected = 2
};

typedef void (^RWRunBlock )(id value);

typedef RWRunBlock ResolveHandler;

typedef void (^RWErrorBlock )(NSError *error);

typedef RWErrorBlock RejectHandler;

typedef void (^RWPromiseBlock )(ResolveHandler resolve, RejectHandler reject);


@interface RWPromise : NSObject
+ (RWPromise *)promise:(RWPromiseBlock)block;

- (RWPromise *(^)(RWRunBlock))then;

- (RWPromise *(^)(RWErrorBlock))catch;

- (RWPromise *(^)(NSArray<RWPromise *> *))all;

- (RWPromise *(^)(NSArray<RWPromise *> *))race;


@end