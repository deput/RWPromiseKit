//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@interface RWRetryPromise : RWPromise

@end

@implementation RWRetryPromise

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"state"]) {
        RWPromiseState newState = [change[NSKeyValueChangeNewKey] unsignedIntegerValue];
        if (newState == RWPromiseStateRejected) {
            [object removeObserver:self forKeyPath:@"state"];
            if (self.catchBlock) {
                self.catchBlock([(RWPromise *) object error]);
            } else {
                self.rejectBlock([(RWPromise *) object error]);
            }
        } else if (newState == RWPromiseStateResolved) {
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }
}

@end

@implementation RWPromise (retry)
- (RWPromise *(^)(NSUInteger))retry {
    __weak RWPromise *wSelf = self;
    return ^RWPromise *(NSUInteger retryCount) {
        RWPromise *newPromise = nil;
        newPromise = [[RWRetryPromise alloc] init:^(ResolveHandler resolve, RejectHandler reject) {
            __strong RWPromise *sSelf = wSelf;
            resolve(sSelf);
        }];

        BOOL thenBlock = NO;
        id block = self.promiseBlock;
        if (self.thenBlock != nil) {
            block = self.thenBlock;
            thenBlock = YES;
        }
        
        __weak RWPromise* wPromise = newPromise;
        
        newPromise.catchBlock = ^(NSError *e){
            static NSUInteger retried = 0;
            if (retried++ < retryCount){
                if (thenBlock) {
                    @autoreleasepool {
                        __weak RWPromise *retryPromise = nil;
                        //dispatch_async(dispatch_get_main_queue(), ^{
                        retryPromise = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
                            @try {
                                id v = ((RWRunBlock)block)(wSelf.valueKeptForRetry);
                                resolve(v);
                            } @catch (NSException *exception) {
                                reject([RWPromise errorWithException:exception]);
                            }
                        }];
                        wPromise.resolveBlock(retryPromise);
                    }
                }else{
                    RWPromise *retryPromise = nil;
                    retryPromise = [RWPromise promise:block];
                    wPromise.resolveBlock(retryPromise);
                }
            }else{
                wPromise.rejectBlock(e);
            }
        };
        return newPromise;
    };
}
@end