#import "RWPromise.h"
#import "RWThenable.h"


@interface MyObject :NSObject <RWThenable>
@end

@implementation MyObject

- (RWPromiseBlock)then {
    return ^(ResolveHandler resolve, RejectHandler reject) {

    };
}


@end

__unused __attribute__((constructor)) static void _() {
//    @autoreleasepool {
//        [RWProgressPromise promise:^(ResolveHandler resolve, RejectHandler reject, ProgressHandler progress) {
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                progress(0.5,@"Hi");
//                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                    progress(0.5,@"BYE");
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1. * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//                        resolve(@"Over");
//                    });
//                });
//            });
//        }].progress(^(double propotion, id value){
//            
//            NSLog(@"%@",value);
//        }).then(^id(id value){
//            NSLog(@"%@",value);
//            return nil;
//        });
//    }
    
}