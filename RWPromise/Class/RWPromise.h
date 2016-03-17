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

+ (RWPromise *)timeout:(NSTimeInterval)timeInSec;

+ (RWPromise *)resolve:(id)value;

+ (RWPromise *)reject:(id)value;

@end

@interface RWPromise (all)
+ (RWPromise *)all:(NSArray<RWPromise *> *)promises;
@end

@interface RWPromise (race)
+ (RWPromise *)race:(NSArray<RWPromise *> *)promises;
@end

@interface RWPromise (then)
- (RWPromise *(^)(RWRunBlock))then;
@end

@interface RWPromise (catch)
- (RWPromise *(^)(RWErrorBlock))catch;
@end

@interface RWPromise (after)
- (RWPromise *(^)(NSTimeInterval))after;
@end