# CoreFoundation Stub Milestone

CoreFoundation linking has been validated with a real Mach-O framework stub.

Validated test:
- Project: `~/CoreFoundationTest`
- Symbol/function use:
  - `CFStringCreateWithCString`
  - `kCFAllocatorDefault`
  - `kCFStringEncodingUTF8`
- Output:
  - `com.bitcrusher32.corefoundationtest_0.0.1-1+debug_iphoneos-arm.deb`

Important finding:
Framework stubs need both:
1. A real Mach-O framework binary:
   `CoreFoundation.framework/CoreFoundation`
2. A `Headers` symlink pointing to the real SDK headers:
   `CoreFoundation.framework/Headers -> $THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/CoreFoundation.framework/Headers`

Without the `Headers` symlink, an early `-F` machostubs path causes Clang to resolve the stub framework first and fail to find headers.

Current validated stubs:
- `usr/lib/libobjc.dylib`
  - `_objc_getClass`
- `usr/lib/libSystem.dylib`
  - `dyld_stub_binder`
- `System/Library/Frameworks/CoreFoundation.framework/CoreFoundation`
  - `_CFStringCreateWithCString`
  - `_kCFAllocatorDefault`

Caveat:
These are linker stubs only. They are not runtime implementations. The target device provides the real frameworks at runtime.
