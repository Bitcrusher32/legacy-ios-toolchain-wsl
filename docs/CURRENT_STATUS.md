# Current Status

Current scope: V1 legacy iOS ARMv7 toolchain + Theos host-side preservation/reproducibility.

## Complete

- Legacy ARMv7 iOS toolchain build/install/verify on WSL Ubuntu 24.04
- Fresh reproducible toolchain build using:
  - `scripts/build-toolchain.sh`
  - `scripts/apply-linux-wsl-patches.py`
- ARMv7 Mach-O smoke verification using:
  - `scripts/verify-toolchain.sh`
- Theos toolchain wrapper setup using:
  - `scripts/setup-theos-toolchain-links.sh`
- Mach-O SDK stub generation using:
  - `scripts/build-ios-machostubs.sh`
- No-op Theos tweak package
- Objective-C runtime symbol package
- CoreFoundation symbol package
- Foundation symbol package
- Logos/MobileSubstrate minimal hook package
- Repo-hosted examples
- Full host validation pipeline:
  - `scripts/validate-host-pipeline.sh`
- WSL appliance export
- WSL appliance import/restore test
- Restored appliance host validation
- NoOpTweak device install/file-placement/uninstall
- NoOpTweak device runtime/respring lifecycle

## Current validated ladder

1. Toolchain smoke verification
2. Theos wrapper setup
3. Mach-O SDK stub generation
4. No-op tweak package
5. Objective-C runtime package
6. CoreFoundation package
7. Foundation package
8. Logos/MobileSubstrate minimal hook package
9. WSL export
10. WSL import/restore validation
11. NoOpTweak device install/file-placement/uninstall
12. NoOpTweak runtime/respring/uninstall lifecycle

## Not yet validated

- LogosHookTest device runtime behavior
- SpringBoard runtime hook behavior on the real iPhone
- FakeGPS logic
- CoreLocation/locationd spoofing
- System-wide spoofing
- Preferences/UI

## Important caveats

Generated Mach-O stubs are host-side linker aids only. They are not runtime implementations.

The target device is expected to provide the real iOS frameworks and MobileSubstrate/CydiaSubstrate behavior at runtime.

Modern `.tbd` SDK stubs are not consumed by the recovered legacy `ld64`; real Mach-O stub binaries are required for old `ld64` host-side linking.

The exported WSL appliance tar is private and should not be published.
