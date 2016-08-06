//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef id (^RWRunBlock )(id value);

typedef void (^ResolveHandler )(id value);

typedef void (^RWErrorBlock )(NSError *error);

typedef RWErrorBlock RejectHandler;

typedef void (^RWPromiseBlock )(ResolveHandler resolve, RejectHandler reject);

typedef void (^ProgressHandler )(double proportion, id value);

NSError* promiseErrorWithReason(NSString* reason);

typedef void (^RWProgressPromiseBlock )(ResolveHandler resolve, RejectHandler reject, ProgressHandler progress);

@interface RWPromise : NSObject
+ (RWPromise *)promise:(RWPromiseBlock)block;

+ (RWPromise *)timer:(NSTimeInterval)timeInSec;

+ (RWPromise *)resolve:(id)value;

+ (RWPromise *)reject:(id)value;

- (void) resolve:(id)value;

- (void) reject:(NSError *)error;

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

@interface RWPromise (finally)
- (void (^)(dispatch_block_t))finally;
@end

@interface RWPromise (timeout)
- (RWPromise *(^)(NSTimeInterval))timeout;
@end

@interface RWPromise (retry)
- (RWPromise *(^)(NSUInteger))retry;
@end

typedef RWPromise* (^RWMapFuncBlock )(id value);

@interface RWPromise (map)
+ (RWPromise *) map:(NSArray *) array :(RWMapFuncBlock) mapFunc;
@end

typedef BOOL (^RWFilterFuncBlock )(id value);

@interface RWPromise (filter)
+ (RWPromise *) filter:(NSArray *) array :(RWFilterFuncBlock) filterFunc;
@end

typedef RWPromise* (^RWReduceFuncBlock )(id item, id acc);

@interface RWPromise (reduce)
+ (RWPromise *) reduce:(NSArray *) array :(RWReduceFuncBlock) reduceFunc initialValue:(id)initialValue;
@end

@interface RWProgressPromise : RWPromise

+ (RWProgressPromise *)promise:(RWProgressPromiseBlock)block;

@property(nonatomic, readonly) ProgressHandler progressHandler;

- (RWPromise *(^)(ProgressHandler)) progress;

- (void) progress:(double) proportion :(id)value;
@end


