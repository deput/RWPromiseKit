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

}