#include <CoreFoundation/CoreFoundation.h>

extern "C" void CoreFoundationTestMarker(void) {
    volatile CFStringRef s = CFStringCreateWithCString(
        kCFAllocatorDefault,
        "legacy-ios-toolchain-test",
        kCFStringEncodingUTF8
    );
    (void)s;
}
