#import "RWPromise.h"

__attribute__((constructor)) static void func() {

    @autoreleasepool {
        RWPromise *p1 = [RWPromise promise:^(ResolveHandler resolve, RejectHandler reject) {
            NSLog(@"promize");
//            NSException *e = [NSException
//                    exceptionWithName:@"FileNotFoundException"
//                               reason:@"File Not Found on System"
//                             userInfo:nil];
//            @throw e;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t) (2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

                resolve(@"Hello from 1");
                //reject([NSError errorWithDomain:@"RWPromise" code:1 userInfo:@{}]);
            });
        }];

        p1.then(^(id value) {
                    NSLog(@"then 1 - %@", value);
//                                NSException *e = [NSException
//                    exceptionWithName:@"FileNotFoundException"
//                               reason:@"File Not Found on System"
//                             userInfo:nil];
//            @throw e;
                })
                .then(^(id value) {
                    NSLog(@"and then 2 - %@", value);
                })
                .catch(^(NSError *error) {

                    NSLog(@"%@", @"Catch ya 1!");
                })
                .after(10)
                .then(^(id value) {
                    NSLog(@"and then 3 - %@", value);
                }).after(10)
                .then(^(id value) {
                    NSLog(@"and then 4 - %@", value);
                });
        ;
//        .then(^(id value) {
//            NSLog(@"and then 3 - %@", value);
//        });


//        p1.then(^(id value) {
//            NSLog(@"hey then - %@", value);
//            //return nil;
//        })

        NSArray *ps = @[[RWPromise timeout:1], [RWPromise timeout:3], p1];
        [RWPromise race:ps].then(^(id value) {
                    NSLog(@"All!");
                })
                .catch(^(NSError *e) {
                    NSLog(e);
                });
        NSLog(@"Hi");
    }
}