//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"


static NSString * RWPromiseErrorDomain = @"RWPromiseErrorDomain";

@implementation RWPromise (Error)
+ (NSError *)errorWithException:(NSException *)exception {
    return [NSError errorWithDomain:RWPromiseErrorDomain code:RWPromiseRuntimeError userInfo:@{@"excepiton":exception}];
}

+ (NSError *)errorOfReject:(NSError *)actualError {
    return [NSError errorWithDomain:RWPromiseErrorDomain code:RWPromiseRejectError userInfo:@{@"error":actualError}];
}

+ (NSError *)errorWithValue:(id)value {
    return [NSError errorWithDomain:RWPromiseErrorDomain code:RWPromiseRejectError userInfo:@{@"value":value}];
}

+ (NSError *)errorWithReason:(NSString *)reason {
    return [NSError errorWithDomain:RWPromiseErrorDomain code:RWPromiseRejectError userInfo:@{@"reason":reason}];
}

+ (NSError *)errorWithUserInfo:(NSDictionary *)userInfo {
    return [NSError errorWithDomain:RWPromiseErrorDomain code:RWPromiseRejectError userInfo:userInfo];
}

@end