# CydiaSubstrate Stub Milestone

A minimal Logos/MobileSubstrate hook package has been validated host-side with a real Mach-O CydiaSubstrate framework stub.

Validated test:
- Project: `~/LogosHookTest`
- Hook:
  - `%hook SpringBoard`
  - `-applicationDidFinishLaunching:`
  - `%orig`
- Output:
  - `com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb`

Validated host-side pipeline:
- Logos preprocessing
- Objective-C++ compilation
- Darwin linking
- ldid signing
- staging into `/Library/MobileSubstrate/DynamicLibraries`
- `.deb` creation

Symbols currently exported by the CydiaSubstrate Mach-O stub:
- `_MSHookMessageEx`
- `_MSHookFunction`

Framework-stub rule:
Generated framework stubs need both:
1. A real Mach-O framework binary:
   - `CydiaSubstrate.framework/CydiaSubstrate`
2. A `Headers` symlink pointing to the real Theos vendor framework headers:
   - `CydiaSubstrate.framework/Headers -> $THEOS/vendor/lib/CydiaSubstrate.framework/Headers`

Important path note:
CydiaSubstrate lives under:

    /Library/Frameworks/CydiaSubstrate.framework

not:

    /System/Library/Frameworks

So wrapper scripts need an early `-F$HOME/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks` path.

Caveat:
This is host-side package validation only. The generated CydiaSubstrate framework is a linker stub, not a runtime implementation. The target iPhone provides the real MobileSubstrate/CydiaSubstrate behavior at runtime.
