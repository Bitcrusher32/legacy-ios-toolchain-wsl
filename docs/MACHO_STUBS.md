# Mach-O Stub Strategy

The recovered legacy `ld64` used by this WSL legacy iOS toolchain does not consume modern `.tbd` text-based SDK stubs.

## Observed behavior

- `.tbd` files symlinked as `.dylib` or framework binaries are found by `ld64` but ignored as unsupported text format.
- No-op tweak packages can build with the temporary `.tbd` overlay only because no real external runtime symbols are referenced.
- Real Objective-C/Foundation/CoreFoundation references require real Mach-O stubs.

## Validated stubs

### `usr/lib/libobjc.dylib`

Initial exported symbol:

- `_objc_getClass`

Validated by:

- `~/ObjCRuntimeTest`
- package: `com.bitcrusher32.objcruntimetest_0.0.1-1+debug_iphoneos-arm.deb`

### `usr/lib/libSystem.dylib`

Initial exported symbol:

- `dyld_stub_binder`

Used to satisfy lazy-binding support needed after `libobjc` was accepted.

### `System/Library/Frameworks/CoreFoundation.framework/CoreFoundation`

Initial exported symbols:

- `_CFStringCreateWithCString`
- `_kCFAllocatorDefault`

Validated by:

- `~/CoreFoundationTest`
- package: `com.bitcrusher32.corefoundationtest_0.0.1-1+debug_iphoneos-arm.deb`

### `System/Library/Frameworks/Foundation.framework/Foundation`

Initial exported symbols:

- `_NSClassFromString`
- `___CFConstantStringClassReference`

Validated by:

- `~/FoundationTest`
- package: `com.bitcrusher32.foundationtest_0.0.1-1+debug_iphoneos-arm.deb`

## Framework-stub rule

Generated framework stubs need both:

1. A real Mach-O framework binary:
   - `FrameworkName.framework/FrameworkName`
2. A `Headers` symlink pointing to the real SDK headers:
   - `FrameworkName.framework/Headers -> $THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/FrameworkName.framework/Headers`

Without the `Headers` symlink, an early `-F` machostubs path can make Clang resolve the stub framework first and then fail to find headers.

## Modern Clang compatibility

The iPhoneOS9.3 Foundation headers trigger nullability diagnostics that become fatal under Theos' `-Werror`.

The wrapper scripts suppress:

- `-Wno-nullability-inferred-on-nested-type`
- `-Wno-nullability-completeness-on-arrays`
- `-Wno-nullability-completeness`

## Caveats

These stubs are host-side linker aids only. They are not runtime implementations.

Do not treat current test packages as device-safe production tweaks. The next unresolved areas are:

- Logos hook revalidation
- MobileSubstrate/CydiaSubstrate link stubs
- Harmless install/uninstall workflow
