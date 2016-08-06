//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise+Internal.h"

@implementation RWProgressPromise
{
    //ProgressHandler _progressHandler;
}

+ (RWProgressPromise *)promise:(RWProgressPromiseBlock)block
{
    RWProgressPromise* progressPromise = [[RWProgressPromise alloc] init];
    __weak RWProgressPromise* weakPromise = progressPromise;
    
    [progressPromise privateInitialize];
    [progressPromise setProgressHandler: ^(double proportion, id value){
        weakPromise.progressBlock(proportion, value);
    }];
    
    progressPromise.promiseBlock = ^(ResolveHandler resolve, RejectHandler reject){
        block(resolve,reject,weakPromise.progressHandler);
    };
    [progressPromise run];
    
    return progressPromise;
}

- (RWPromise *(^)(ProgressHandler)) progress
{
    __weak RWProgressPromise *wSelf = self;
    return ^RWPromise *(ProgressHandler progressBlock){
        wSelf.progressBlock = progressBlock;
        return wSelf;
    };
}

- (void) setProgressHandler:(ProgressHandler)progressHandler
{
    _progressHandler = progressHandler;
}

- (void) progress:(double) proportion :(id)value
{
    self.progressHandler(proportion,value);
}
@end