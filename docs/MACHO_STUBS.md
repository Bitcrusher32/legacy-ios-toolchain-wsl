# Mach-O Stub Strategy

The recovered legacy `ld64` used by this WSL legacy iOS toolchain does not consume modern `.tbd` text-based SDK stubs.

## Observed behavior

- `.tbd` files symlinked as `.dylib` or framework binaries are found by `ld64` but ignored as unsupported text format.
- No-op packages can build without real external symbol references, but real Objective-C/Foundation/CoreFoundation/Substrate references require real Mach-O stubs.
- A real Mach-O stub can be generated locally with the recovered assembler/linker and placed before `.tbd` SDK paths.

## Generated stub root

Default:

    ~/ios-sdk-machostubs/iPhoneOS9.3

Override:

    IOS_MACHOSTUBS_ROOT=/custom/path ./scripts/build-ios-machostubs.sh

## Validated stubs

### `usr/lib/libobjc.dylib`

Initial exported symbol:

- `_objc_getClass`

Validated by:

- `examples/objc-runtime-test/`

### `usr/lib/libSystem.dylib`

Initial exported symbol:

- `dyld_stub_binder`

Used to satisfy lazy-binding support needed after `libobjc` is accepted.

### `System/Library/Frameworks/CoreFoundation.framework/CoreFoundation`

Initial exported symbols:

- `_CFStringCreateWithCString`
- `_kCFAllocatorDefault`

Validated by:

- `examples/corefoundation-test/`

### `System/Library/Frameworks/Foundation.framework/Foundation`

Initial exported symbols:

- `_NSClassFromString`
- `___CFConstantStringClassReference`

Validated by:

- `examples/foundation-test/`

### `Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate`

Initial exported symbols:

- `_MSHookMessageEx`
- `_MSHookFunction`

Validated by:

- `examples/logos-hook-test/`

## Framework-stub rule

Generated framework stubs need both:

1. A real Mach-O framework binary:
   - `FrameworkName.framework/FrameworkName`
2. A valid `Headers` symlink:
   - SDK frameworks point to the real SDK headers.
   - CydiaSubstrate points to Theos vendor framework headers.

Without the `Headers` symlink, an early `-F` machostubs path can make Clang resolve the stub framework first and then fail to find headers.

## Modern Clang compatibility

The iPhoneOS9.3 Foundation headers trigger nullability diagnostics that become fatal under Theos' `-Werror`.

The wrapper scripts suppress:

- `-Wno-nullability-inferred-on-nested-type`
- `-Wno-nullability-completeness-on-arrays`
- `-Wno-nullability-completeness`

The wrapper scripts also strip incompatible module flags from Theos' generated compiler invocations.

## Caveats

These stubs are host-side linker aids only. They are not runtime implementations.

Do not treat current test packages as device-safe production tweaks.

The next unresolved areas are:

- harmless device install/uninstall workflow
- runtime behavior on the actual iPhone
- application-specific logic
