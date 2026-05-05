# Foundation Stub Milestone

Foundation linking has been validated with a real Mach-O framework stub.

Validated test:
- Project: `~/FoundationTest`
- Symbol/function use:
  - `NSClassFromString(@"NSObject")`
- Output:
  - `com.bitcrusher32.foundationtest_0.0.1-1+debug_iphoneos-arm.deb`

Symbols currently exported by the Foundation Mach-O stub:
- `_NSClassFromString`
- `___CFConstantStringClassReference`

Important finding:
Foundation headers from the iPhoneOS9.3 SDK trigger modern Clang nullability diagnostics that become fatal under Theos' `-Werror`.

Wrapper-level suppressions required:
- `-Wno-nullability-inferred-on-nested-type`
- `-Wno-nullability-completeness-on-arrays`
- `-Wno-nullability-completeness`

Framework-stub rule:
Generated framework stubs need both:
1. A real Mach-O framework binary:
   `Foundation.framework/Foundation`
2. A `Headers` symlink pointing to the real SDK headers:
   `Foundation.framework/Headers -> $THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/Foundation.framework/Headers`

Caveat:
These are linker stubs only. They are not runtime implementations. The target device provides the real frameworks at runtime.
