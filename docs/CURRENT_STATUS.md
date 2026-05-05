# Current Status

Validated host-side as of the Foundation milestone.

## Complete

- Legacy ARMv7 iOS toolchain build/install/verify on WSL Ubuntu 24.04
- Fresh reproducible toolchain build using:
  - `scripts/build-toolchain.sh`
  - `scripts/apply-linux-wsl-patches.py`
- ARMv7 Mach-O smoke verification using:
  - `scripts/verify-toolchain.sh`
- Theos toolchain wrapper setup using:
  - `scripts/setup-theos-toolchain-links.sh`
- No-op Theos tweak compile/link/sign/package
- Objective-C runtime symbol test package using Mach-O stubs:
  - `libobjc.dylib`
  - `libSystem.dylib`
- CoreFoundation symbol test package using:
  - `CoreFoundation.framework/CoreFoundation`
  - `CoreFoundation.framework/Headers -> real SDK Headers`
- Foundation symbol test package using:
  - `Foundation.framework/Foundation`
  - `Foundation.framework/Headers -> real SDK Headers`
- Logos/MobileSubstrate hook package using:
  - `CydiaSubstrate.framework/CydiaSubstrate`
  - `CydiaSubstrate.framework/Headers -> real Theos vendor Headers`

## Current validated ladder

1. No-op package: validated
2. Objective-C runtime package: validated
3. CoreFoundation package: validated
4. Foundation package: validated
5. Logos/MobileSubstrate minimal hook package: validated host-side

## Not yet validated

- Harmless device install/uninstall
- FakeGPS logic
- System-wide GPS spoofing
- Preferences/UI

## Important caveats

Generated Mach-O stubs are host-side linker aids only. They are not runtime implementations.

The target device is expected to provide the real iOS frameworks at runtime. No device install has been attempted yet.

Modern `.tbd` SDK stubs are not consumed by the recovered legacy `ld64`; real Mach-O stub binaries are required for old `ld64` host-side linking.
