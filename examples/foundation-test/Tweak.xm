#import <Foundation/Foundation.h>

extern "C" void FoundationTestMarker(void) {
    volatile Class cls = NSClassFromString(@"NSObject");
    (void)cls;
}
