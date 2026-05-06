# Legacy iOS ARMv7 Toolchain Appliance for WSL Ubuntu 24.04

Patched build scripts, Theos wrapper setup, Mach-O stub generation, validation examples, and WSL appliance documentation for building legacy iOS ARMv7 tweaks from WSL Ubuntu 24.04.

Author: Bitcrusher32

## Current status

V1 host-side preservation scope is complete.

Validated:

1. Legacy ARMv7 iOS toolchain build/install/verify on WSL Ubuntu 24.04
2. fresh reproducible toolchain build using `scripts/build-toolchain.sh`
3. Theos wrapper setup using `scripts/setup-theos-toolchain-links.sh`
4. Mach-O SDK stub generation using `scripts/build-ios-machostubs.sh`
5. no-op Theos tweak `.deb`
6. Objective-C runtime symbol `.deb`
7. CoreFoundation symbol `.deb`
8. Foundation symbol `.deb`
9. Logos/MobileSubstrate minimal hook `.deb`
10. repo-hosted full host validation pipeline
11. WSL export/import appliance preservation
12. restored appliance host validation
13. NoOpTweak device install/file-placement/uninstall
14. NoOpTweak device runtime/respring lifecycle

Not validated:

- LogosHookTest device runtime behavior
- SpringBoard runtime hook behavior on the real iPhone
- FakeGPS logic
- CoreLocation/locationd spoofing
- preferences/UI

Important caveat:

Generated Mach-O SDK stubs are host-side linker aids only. They are not runtime implementations. The target iPhone provides the real frameworks at runtime.

## Target context

Validated host:

- Windows 11 + WSL2
- Ubuntu 24.04.3 LTS

Validated target build context:

- iPhone 4s
- iOS 6.1.3
- ARMv7
- Theos target: `iphone:clang:9.3:6.1`

Compatibility with other devices/iOS versions is unverified.

## Base toolchain project

Base project:

    https://github.com/Tidal-Loop/linux-ios-toolchain

This repository acts as the WSL/Linux reproducibility controller around that older toolchain.

## Fresh toolchain build

Install dependencies:

    ./scripts/install-deps-ubuntu-24.04.sh

Build/install the toolchain:

    ./scripts/build-toolchain.sh

Verify installed tools:

    ./scripts/verify-toolchain.sh

The live source patching path is:

    scripts/apply-linux-wsl-patches.py

Old hand-written patch sketches are retained only under:

    docs/obsolete-patch-sketches/

## Theos setup

After the legacy toolchain is installed, run:

    ./scripts/setup-theos-toolchain-links.sh

This installs Theos wrapper scripts/symlinks under:

    $THEOS/toolchain/linux/iphone/bin

The wrappers:

- answer Theos version probes
- strip incompatible modern Clang module flags
- suppress old SDK nullability warnings
- force Darwin linker discovery with `-B`
- add early Mach-O stub search paths
- wrap `ldid` so `CODESIGN_ALLOCATE` does not break Linux signing

## Mach-O SDK stubs

Modern iPhoneOS SDKs provide `.tbd` text-based stubs. The recovered legacy `arm-apple-darwin-ld` does not consume them directly.

Generate the validated host-side Mach-O stubs with:

    ./scripts/build-ios-machostubs.sh

Current generated stubs:

- `usr/lib/libobjc.dylib`
- `usr/lib/libSystem.dylib`
- `System/Library/Frameworks/CoreFoundation.framework/CoreFoundation`
- `System/Library/Frameworks/Foundation.framework/Foundation`
- `Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate`

Framework stubs also need valid `Headers` symlinks when they appear early in `-F` search paths.

## Full host validation

Run the entire host-side validation ladder:

    ./scripts/validate-host-pipeline.sh

This builds all repo-hosted examples:

- `examples/noop-tweak/`
- `examples/objc-runtime-test/`
- `examples/corefoundation-test/`
- `examples/foundation-test/`
- `examples/logos-hook-test/`

Expected result:

    Host pipeline validation complete.

Generated `.theos/`, `packages/`, and validation logs should not be committed.

Clean generated outputs with:

    ./scripts/clean-generated-artifacts.sh

## Package inspection

Before any device install, inspect a `.deb` on the host:

    ./scripts/inspect-deb-package.sh path/to/package.deb

The first install candidate should be a harmless no-op package, not FakeGPS logic.

## WSL appliance preservation

WSL export/import documentation:

    docs/WSL_APPLIANCE_EXPORT.md

Current appliance manifest:

    docs/APPLIANCE_MANIFEST.md

The WSL export tar is private. Do not publish it or commit it to Git.

## Device safety

Before touching the iPhone, follow:

    docs/DEVICE_INSTALL_SAFETY_PLAN.md
    docs/DEVICE_TRANSFER_WORKFLOW.md
    docs/NOOP_RUNTIME_VALIDATION.md
    docs/LOGOS_RUNTIME_VALIDATION_PLAN.md
    docs/LOGOS_RUNTIME_VALIDATION.md

The next project branch should validate harmless install/uninstall, not GPS spoofing.
