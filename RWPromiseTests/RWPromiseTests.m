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
    XCTAssert([result[1] isEqualToString:@"Timeout"]);
    XCTAssert([result[2] isEqualToString:@"Timeout"]);
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
    
    XCTAssertEqual(result, @"Timeout");
}

- (void) testAfter
{
    __block id result = nil;
    __unused RWPromise* p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
        resolve(@"1");
    }].after(3).then(^id(id value){
        result = value;
        return nil;
    });
    XCTAssertNil(result);
    [NSThread sleepForTimeInterval:5];
    
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
@end
