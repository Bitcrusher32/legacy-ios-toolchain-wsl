# Mach-O Stub Strategy

The legacy ld64 used by this WSL legacy iOS toolchain does not consume modern `.tbd` text-based SDK stubs.

Observed behavior:
- `.tbd` files symlinked as `.dylib` or framework binaries are found by ld64 but ignored as unsupported text format.
- No-op tweak packages can still build because no real external runtime symbols are referenced.
- Real Objective-C references fail unless ld64 sees a real Mach-O dylib stub.

Validated:
- A no-op Theos tweak can compile, link, sign, stage, and package.
- A minimal Objective-C runtime test referencing `_objc_getClass` can package when real Mach-O stubs exist for:
  - `libobjc.dylib` exporting `_objc_getClass`
  - `libSystem.dylib` exporting `dyld_stub_binder`

Current caveats:
- Foundation and CoreFoundation real symbol linking is not solved yet.
- MobileSubstrate/CydiaSubstrate linking is not solved yet.
- These stubs are host-side linker aids, not runtime implementations.
- Do not treat current test packages as device-safe production tweaks.

## Foundation validated

Foundation baseline linking has now been validated with:
- `Foundation.framework/Foundation`
- `Foundation.framework/Headers -> real SDK Headers`

Initial exported symbols:
- `_NSClassFromString`
- `___CFConstantStringClassReference`

Modern Clang requires nullability warning suppressions for iPhoneOS9.3 Foundation headers when Theos uses `-Werror`.
