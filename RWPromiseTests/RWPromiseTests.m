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

@end
