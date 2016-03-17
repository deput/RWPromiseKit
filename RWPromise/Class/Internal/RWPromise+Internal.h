//
// Created by deput on 3/12/16.
// Copyright (c) 2016 RW. All rights reserved.
//

#import "RWPromise.h"

#define STATE_PROTECT if (sSelf.state != RWPromiseStatePending) return;

@interface RWPromise ()

@property(nonatomic) id value;
@property(nonatomic) NSError *error;
@property(atomic, assign) RWPromiseState state;

@property(nonatomic, strong) id strongSelf;

@property(nonatomic, strong) RWPromise *depPromise;

@property(nonatomic, copy) ResolveHandler resolveBlock;

@property(nonatomic, copy) RejectHandler rejectBlock;

@property(nonatomic, copy) RWPromiseBlock promiseBlock;

@property(nonatomic, copy) RejectHandler catchBlock;

@property(nonatomic, copy) ResolveHandler thenBlock;

@property(nonatomic, copy) NSString *identifier;

- (instancetype)init:(RWPromiseBlock)initBlock;

- (void)keepAlive;

- (void)losingControl;

- (void)run;
@end




