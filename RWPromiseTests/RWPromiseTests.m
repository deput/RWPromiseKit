//
//  RWPromiseTests.m
//  RWPromiseTests
//
//  Created by yuguo on 3/12/16.
//  Copyright (c) 2016 RW. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "RWPromise.h"

@interface RWPromiseTests : XCTestCase

@end

@implementation RWPromiseTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


- (void) testPromizeLifeCycle
{
    __weak id object = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            
        }];
        object = p1;
    }
    
    XCTAssertNotNil(object,@"Promise won't be dealloced until resolved");
    
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(nil);
        }];
        object = p1;
    }
    
    XCTAssertNil(object,@"Promise will be dealloced until resolved");
    
    object = @"Not nil";
    @autoreleasepool {
        RWPromise* p1 = [RWProgressPromise promise:^(ResolveHandler resolve, RejectHandler reject, ProgressHandler progress) {
            resolve(nil);
        }].progress(^(double proportion, id value){
        
        });
        object = p1;
    }
    
    XCTAssertNil(object,@"Promise will be dealloced until resolved");
}

- (void) testThen
{
    NSString* expectedRes = @"res";
    __block NSString* result = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(expectedRes);
        }];
        p1.then(^id(id value){
            result = value;
            return @"Done";
        });
    }
    
    XCTAssertEqual(result, expectedRes);
    
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(@"1");
        }];
        p1
        .then(^id(NSString* value){
            return [value stringByAppendingString:@"2"];
        })
        .then(^id(NSString* value){
            return [value stringByAppendingString:@"3"];
        })
        .then(^id(NSString* value){
            result = value;
            return nil;
        });
    }
    
    XCTAssertTrue([result isEqualToString:@"123"]);
}

- (void) testCatch{
    __block NSError* err = nil;
    
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject([NSError errorWithDomain:@"mydomain" code:1 userInfo:nil]);
        }];
        p1
        .catch(^(NSError* error){
            err = error;
        });
    }
    
    XCTAssertTrue([err.domain isEqualToString:@"mydomain"]);
    
    err = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject([NSError errorWithDomain:@"mydomain" code:1 userInfo:nil]);
        }];
        p1
        .then(^id(NSString* value){
            return [value stringByAppendingString:@"2"];
        })
        .then(^id(NSString* value){
            return [value stringByAppendingString:@"3"];
        })
        .catch(^(NSError* error){
            err = error;
        });
    }
    
    XCTAssertTrue([err.domain isEqualToString:@"mydomain"]);
    
    
    err = nil;
    
    __block id res = @"might be nil or not";
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject([NSError errorWithDomain:@"mydomain" code:1 userInfo:nil]);
        }];
        p1
        .then(^id(NSString* value){
            return [value stringByAppendingString:@"2"];
        })
        .catch(^(NSError* error){
            err = error;
        })
        .then(^id(id value){
            res = value;
            return nil;
        });
    }
    
    XCTAssertTrue([err.domain isEqualToString:@"mydomain"]);
    XCTAssertNil(res);
}

- (void) testCatch2
{
    __block NSError* err = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            NSException *e = [NSException
                    exceptionWithName:@"name"
                               reason:@"reason"
                              userInfo:@{}];
            @throw e;
        }];
        p1
        .catch(^(NSError* error){
            err = error;
        });
    }
    XCTAssertTrue([[[err userInfo][@"excepiton"] name] isEqualToString:@"name"],@"Should catch the exception");
    
    
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(nil);
        }];
        p1.then(^id(id value){
            NSString* s = @"s";
            [s doesNotRecognizeSelector:@selector(addObject:)];
            return nil;
        })
        .catch(^(NSError* error){
            err = error;
        });
    }
    XCTAssertTrue([[[err userInfo][@"excepiton"] name] isEqualToString:@"NSInvalidArgumentException"]);
}


- (void) testThenNestedPromise{
    __block NSString* result = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(@"1");
        }];
        p1.then(^id(NSString* value){
            result = value;
            RWPromise* p2 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
                resolve(@"2");
            }];
            return p2;
        })
        .then(^id(NSString* value){
            result = [result stringByAppendingString:value];
            return nil;
        });
    }
    
    XCTAssertTrue([result isEqualToString:@"12"]);
}

- (void) testTimeout{
    __weak id object = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise timer:1];
        p1.then(^id(NSString* value){
            return nil;
        });
        object = p1;
    }
    XCTAssertNotNil(object);
    
    [NSThread sleepForTimeInterval:1.5];
//    dispatch_semaphore_t sem = dispatch_semaphore_create(0);
//    dispatch_semaphore_wait(sem, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)));
    XCTAssertNil(object);
}

- (void) testAll1
{
    __block NSArray* result = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(@"1");
        }];
        
        RWPromise* p2 = [RWPromise timer:1];
        RWPromise* p3 = [RWPromise timer:2];
        
        [RWPromise all:@[p1,p2,p3]].then(^id(NSArray* values){
            result = values;
            return nil;
        });
        
    }
    [NSThread sleepForTimeInterval:3];
    XCTAssert([result[0] isEqualToString:@"1"]);
    XCTAssert([[result[1] allKeys][0] isEqualToString:@"Timeout"]);
    XCTAssert([[result[2] allKeys][0]  isEqualToString:@"Timeout"]);
}

- (void) testAll2
{
    __block id result = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject(promiseErrorWithReason(@"on purpose"));
        }];
        
        RWPromise* p2 = [RWPromise timer:1];
        RWPromise* p3 = [RWPromise timer:2];
        
        [RWPromise all:@[p1,p2,p3]].then(^id(NSArray* values){
            result = values;
            return nil;
        }).catch(^(NSError* error){
            result = error;
        });
        
    }
    [NSThread sleepForTimeInterval:3];
    
    XCTAssert([result isKindOfClass:[NSError class]]);
    XCTAssert([[result userInfo][@"reason"] isEqualToString:@"on purpose"]);
}

- (void) testRace1
{
    __block NSArray* result = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(@"1");
        }];
        
        RWPromise* p2 = [RWPromise timer:1];
        RWPromise* p3 = [RWPromise timer:2];
        
        [RWPromise race:@[p1,p2,p3]].then(^id(id value){
            result = value;
            return nil;
        });
        
    }
    [NSThread sleepForTimeInterval:3];
    XCTAssert([(NSString*)result isEqualToString:@"1"]);
}

- (void) testRace2
{
    __block NSArray* result = nil;
    @autoreleasepool {
        
        RWPromise* p2 = [RWPromise timer:1].then(^id (id value){
            return @"2";
        });

        RWPromise* p3 = [RWPromise timer:2].then(^id (id value){
            return @"3";
        });
        
        [RWPromise race:@[p2,p3]].then(^id(id value){
            result = value;
            return nil;
        });
        
    }
    [NSThread sleepForTimeInterval:3];
    XCTAssert([(NSString*)result isEqualToString:@"2"]);
}

- (void) testRace3
{
    __block id result = nil;
    @autoreleasepool {
        RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject(promiseErrorWithReason(@"1"));
        }];
        
        RWPromise* p2 = [RWPromise timer:1].then(^id (id value){
            NSException *e = [NSException
                              exceptionWithName:@"name"
                              reason:@"reason"
                              userInfo:@{}];
            @throw e;
            return @"2";
        });
        
        RWPromise* p3 = [RWPromise timer:2].then(^id (id value){
            NSException *e = [NSException
                              exceptionWithName:@"name"
                              reason:@"reason"
                              userInfo:@{}];
            @throw e;
            return @"3";
        });
        
        [RWPromise race:@[p1,p2,p3]].then(^id(id value){
            result = value;
            return nil;
        }).catch(^(NSError* error){
            result = error;
        });
        
    }
    [NSThread sleepForTimeInterval:3];
    XCTAssert([result isKindOfClass:[NSError class]]);
}

- (void) testTimeout2
{
    __block id result = nil;
    __unused RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
        
    }].timeout(3).then(^id(id value){
        result = value;
        return nil;
    });
    XCTAssertNil(result);
    [NSThread sleepForTimeInterval:4];
    
    XCTAssertEqual([result allKeys][0] , @"Timeout");
}

- (void) testAfter
{
    __block id result = nil;
    __unused RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
        resolve(@"1");
    }]
    .after(3)
    .then(^id(id value){
        result = value;
        return nil;
    });
    XCTAssertNil(result);
    
    //[NSThread sleepForTimeInterval:5];
    //XCTAssertEqual(result, @"1");
}


- (void) testFinally
{
    __block id result = nil;
    @autoreleasepool {
        [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(@"1");
        }].then(^id(id value){
            result = value;
            return nil;
        }).catch(^(NSError* error){
        
        }).finally(^{
            result = @"finally";
        });
    }
    
    XCTAssertEqual(result, @"finally");
    
    @autoreleasepool {
        [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            reject(nil);
        }].then(^id(id value){
            result = value;
            return nil;
        }).catch(^(NSError* error){
            
        }).finally(^{
            result = @"finally";
        });
    }
    
    XCTAssertEqual(result, @"finally");
}

- (void) testRetry1
{
    NSUInteger retryCount = 3;
    __block NSMutableArray* res = @[].mutableCopy;
    __block NSString* final = nil;
    @autoreleasepool {
        [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            static NSUInteger triedCount = 0;
            triedCount++;
            [res addObject:@(triedCount)];
            if (triedCount == retryCount) {
                resolve(@"ahha");
            }else{
                reject(promiseErrorWithReason(@"needRetry"));
            }
            
        }]
        .retry(retryCount)
        .then(^id(id value){
            final = value;
            return nil;
        });
    }
    XCTAssert(res.count == retryCount);
    XCTAssertTrue([final isEqualToString:@"ahha"]);
}

- (void) testRetry2
{
    NSUInteger retryCount = 3;
    __block NSMutableArray* res = @[].mutableCopy;
    __block id final = nil;
    @autoreleasepool {
        [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            static NSUInteger triedCount = 0;
            triedCount++;
            [res addObject:@(triedCount)];
            reject(promiseErrorWithReason(@"needRetry"));
        }]
        .retry(retryCount)
        .then(^id(id value){
            final = value;
            return nil;
        })
        .catch(^(NSError* e){
            final = e;
        });
    }
    XCTAssert(res.count == retryCount + 1);
    XCTAssert([final isKindOfClass:[NSError class]]);
}

- (void) testRetry3
{
    NSUInteger retryCount = 3;
    __block NSMutableArray* res = @[].mutableCopy;
    __block id final = nil;
    @autoreleasepool {
        [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            resolve(@"1");
        }]
        .then(^id(id value){
            static NSUInteger triedCount = 0;
            triedCount++;
            [res addObject:[value copy]];
            if (triedCount == retryCount) {
                return @"hola";
            }else{
                NSException *e = [NSException
                                  exceptionWithName:@"name"
                                  reason:@"reason"
                                  userInfo:@{}];
                @throw e;
                return nil;
            }
            return nil;
        })
        .retry(retryCount)
        .then(^id(id value){
            final = value;
            return nil;
        })
        .catch(^(NSError* e){
            final = e;
        });
    }
    XCTAssert(res.count == retryCount);
    XCTAssertTrue([final isEqualToString:@"hola"]);
}

- (void) testMap1
{
    __block NSArray* final = nil;
    @autoreleasepool {
        [RWPromise map:@[@"1",@"2",@"3"] :^RWPromise *(id value) {
            return [RWPromise resolve:value];
        }].then(^id(NSArray* values){
            final = values;
            return nil;
        });
    }
    
    XCTAssertTrue([final isKindOfClass:[NSArray class]]);
    XCTAssertEqual(3, final.count);
    XCTAssertTrue([final containsObject:@"1"]);
    XCTAssertTrue([final containsObject:@"2"]);
    XCTAssertTrue([final containsObject:@"3"]);
}

- (void) testMap2
{
    __block id final = nil;
    @autoreleasepool {
        [RWPromise map:@[@"1",@"2",@"3"] :^RWPromise *(id value) {
            return [RWPromise reject:value];
        }].then(^id(NSArray* values){
            final = values;
            return nil;
        })
        .catch(^(NSError* e){
            final = e;
        });
    }
    
    XCTAssert([final isKindOfClass:[NSError class]]);
}

- (void) testFilter
{
    __block NSArray* final = nil;
    @autoreleasepool {
        [RWPromise filter:@[@1,@2,@3,@4,@5] :^BOOL(NSNumber* number) {
            return number.integerValue % 2 == 0;
        }]
        .then(^id(NSArray* values){
            final = values;
            return nil;
        });
    }
    XCTAssertEqual(2, final.count);
    XCTAssertTrue([final containsObject:@2]);
    XCTAssertTrue([final containsObject:@4]);
}

- (void) testReduce1
{
    __block NSNumber* final = nil;
    @autoreleasepool {
        [RWPromise reduce:@[@1,@2,@3,@4,@5] :^RWPromise *(id item, NSNumber* acc) {
            return [RWPromise resolve:item].then(^id(NSNumber* number){
                return @(acc.integerValue + number.integerValue);
            });
        } initialValue:@(0)]
        .then(^id(NSNumber* value){
            final = value;
            return nil;
        });
    }
    XCTAssertTrue([final isEqualToNumber:@15]);
    
}

- (void) testReduce2
{
    __block NSNumber* final = nil;
    @autoreleasepool {
        [RWPromise reduce:@[@1,@2,@3,@4,@5] :^RWPromise *(id item, NSNumber* acc) {
            return [RWPromise resolve:item].then(^id(NSNumber* number){
                return @(acc.integerValue * number.integerValue);
            });
        } initialValue:@(1)]
        .then(^id(NSNumber* value){
            final = value;
            return nil;
        });
    }
    XCTAssertTrue([final isEqualToNumber:@120]);
    
}


- (void) testProgress
{
    __block NSMutableArray* res = @[].mutableCopy;
    @autoreleasepool {
        RWProgressPromise* p =
        [RWProgressPromise promise:^(ResolveHandler resolve, RejectHandler reject, ProgressHandler progress) {
        }];
        p.progress(^(double propotion, id value){
            [res addObject:value];
        }).then(^id(id value){
            [res addObject:value];
            return nil;
        });
        [p progress:0.f :@1];
        [p progress:1.f :@2];
        [p resolve:@3];
    }
    XCTAssertTrue([res[0] isEqualToNumber:@1]);
    XCTAssertTrue([res[1] isEqualToNumber:@2]);
    XCTAssertTrue([res[2] isEqualToNumber:@3]);
}

@end
