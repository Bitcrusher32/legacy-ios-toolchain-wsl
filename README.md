# Legacy iOS ARMv7 Toolchain Appliance for WSL Ubuntu 24.04

A modernization wrapper for the legacy theros toolchain from a google code archive. Adapted to run in a WSL Ubuntu 24.04LTS environment.

Patched build scripts, Theos integration helpers, Mach-O stub generation, validation examples, WSL appliance documentation, and public/private preservation workflows for rebuilding and validating a legacy iOS ARMv7 toolchain from WSL Ubuntu 24.04.

---
Author: Udaiveer Singh Bhangu (Bitcrusher32)

Attached is this project's LogDocV2.29, a novel human-in-loop iteration system: LogDocV2.29-sanitized.md
See the LogDoc Loop System repo for more information: https://git.bitcrusher32.win/bitcrusher32/logdoc-loop-system 

---

This project began as a recovery effort for an iPhone 4s / iOS 6.1.3 tweak toolchain. The current scope is broader:

- preserve a reproducible legacy ARMv7 iOS toolchain on WSL/Linux
- keep the build/install/verify path reproducible from Git
- preserve a private known-good full WSL appliance
- publish a sanitized public toolchain-only appliance
- validate host-side Theos package generation through representative examples
- validate harmless device-side install/respring/uninstall behavior on a real iPhone 4s
- document edge cases and future target lanes without overclaiming compatibility



## Current status

V2.29 is the current major milestone.

The project now has three preservation layers:

1. **Git recipe**
   - reproducible scripts, docs, and validation examples
   - no generated packages or WSL tar exports committed

2. **Private full WSL appliance**
   - known-good operational environment
   - includes local Theos/SDK/device-workflow state
   - not public and should not be published

3. **Public sanitized toolchain appliance**
   - toolchain-only WSL/rootfs-style appliance
   - public release artifact
   - no Apple SDKs
   - no private WSL user environment
   - no SSH keys, shell history, device credentials, or private backups
   - imported and smoke-tested successfully

---

## Public toolchain appliance

A sanitized public toolchain-only WSL/rootfs-style appliance is available for the V2.28 public release.

Release tag:

    v2.28-public-toolchain

Static appliance URL:

    https://git.bitcrusher32.win/downloads/legacy-ios-toolchain/V2.28/legacy-ios-toolchain-public-toolchain-V2.28.tar

Related docs:

- `docs/PUBLIC_APPLIANCE.md`
- `docs/PUBLIC_HYDRATION_GUIDE.md`

The public appliance validates the recovered ARMv7 toolchain smoke tests. It does **not** include Apple iPhoneOS SDKs and does **not** validate the full Theos/iPhoneOS package pipeline by itself.

Users must provide their own legally obtained SDKs and configure Theos locally for full package validation.

Public appliance validation includes:

- import into a clean WSL distro
- `/PUBLIC_APPLIANCE_README.txt` present
- `/PUBLIC_APPLIANCE_MANIFEST.txt` present
- `./scripts/verify-toolchain.sh` passed
- ARMv7 Mach-O assembler smoke test passed
- ARMv7 relocatable linker smoke test passed
- archive smoke test passed
- `ldid` present

Not included in the public appliance:

- Apple iPhoneOS SDKs
- private WSL user environment
- SSH keys
- shell history
- device credentials
- private device backups
- private full development appliance contents

Not validated by the public appliance alone:

- Theos package pipeline
- iPhoneOS SDK header/framework builds
- MobileSubstrate runtime tests
- device install/respring tests

---

## Validated ladder

Validated on the private/local Lane A environment:

1. Legacy ARMV7 iOS toolchain build/install/verify on WSL Ubuntu 24.04
2. fresh reproducible toolchain build using `scripts/build-toolchain.sh`
3. Theos wrapper setup using `scripts/setup-theos-toolchain-links.sh`
4. Mach-O SDK stub generation using `scripts/build-ios-machostubs.sh`
5. no-op Theos tweak `.deb`
6. Objective-C runtime symbol `.deb`
7. CoreFoundation symbol `.deb`
8. Foundation symbol `.deb`
9. Logos/MobileSubstrate minimal hook `.deb`
10. logging-only Logos hook `.deb`
11. repo-hosted full host validation pipeline through `logos-logging-test`
12. WSL export/import appliance preservation
13. restored private appliance host validation
14. NoOpTweak device install/file-placement/uninstall
15. NoOpTweak controlled runtime/respring lifecycle
16. LogosHookTest device install/file-placement/uninstall
17. LogosHookTest controlled SpringBoard runtime lifecycle
18. LogosLoggingTest host build/package inspection
19. LogosLoggingTest controlled SpringBoard hook-body observability
20. LogosLoggingTest marker creation and cleanup
21. public sanitized toolchain-only WSL appliance export
22. public appliance import and `verify-toolchain.sh` validation
23. public static release distribution with checksum/manifest sidecars

Important caveat:

Generated Mach-O SDK stubs are **host-side linker aids only**. They are not runtime implementations. The target iPhone provides the real libraries/frameworks at runtime.

---

## Target context

Validated host:

- Windows 11 + WSL2
- Ubuntu 24.04.x LTS

Validated private/local target build context:

- iPhone 4s
- iOS 6.1.3
- ARMv7
- Cydia / MobileSubstrate
- Theos target: `iphone:clang:9.3:6.1`

Compatibility with other devices, iOS versions, architectures, or jailbreak setups is unverified unless separately documented in the target matrix.

See:

- `docs/TARGET_MATRIX.md`

---

## Base toolchain project

Base project:

    https://github.com/Tidal-Loop/linux-ios-toolchain

This repository acts as the WSL/Linux reproducibility controller around that older toolchain.

The repo provides:

- dependency install script
- automated build/install script
- idempotent Linux/WSL source patcher
- toolchain smoke verification
- Theos wrapper setup
- Mach-O stub generation
- host validation examples
- device-safety documentation
- public/private appliance preservation docs

---

## Fresh toolchain build

Install dependencies:

    ./scripts/install-deps-ubuntu-24.04.sh

Build/install the toolchain:

    ./scripts/build-toolchain.sh

Verify installed tools:

    ./scripts/verify-toolchain.sh

The live source patching path is:

    scripts/apply-linux-wsl-patches.py

Old manually written patch sketches are retained only under:

    docs/obsolete-patch-sketches/

Expected verification output ends with:

    Verification complete.

---

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

The public appliance does not ship with Apple SDKs or a full private Theos/SDK state. See:

- `docs/PUBLIC_HYDRATION_GUIDE.md`

---

## Mach-O SDK stubs

Modern iPhoneOS SDKs provide `.tbd` text-based stubs. The recovered legacy `arm-apple-darwin-ld` does not consume them directly.

Generate validated host-side Mach-O stubs with:

    ./scripts/build-ios-machostubs.sh

Current generated stubs include:

- `usr/lib/libobjc.dylib`
- `usr/lib/libSystem.dylib`
- `System/Library/Frameworks/CoreFoundation.framework/CoreFoundation`
- `System/Library/Frameworks/Foundation.framework/Foundation`
- `Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate`

Framework stubs also need valid `Headers` symlinks when they appear early in `-F` search paths.

These stubs are only meant to satisfy host-side linking. They are not substitutes for real runtime frameworks on the device.

See:

- `docs/MACHO_STUBS.md`
- `docs/CYDIASUBSTRATE_STUBS.md`

---

## Full host validation

Run the entire host-side validation ladder:

    ./scripts/validate-host-pipeline.sh

This builds all repo-hosted examples:

- `examples/noop-tweak/`
- `examples/objc-runtime-test/`
- `examples/corefoundation-test/`
- `examples/foundation-test/`
- `examples/logos-hook-test/`
- `examples/logos-logging-test/`

Expected result:

    Host pipeline validation complete.

Generated `.theos/`, `packages/`, `.deb`, `.log`, `__pycache__`, and local validation artifacts should not be committed.

Clean generated outputs with:

    ./scripts/clean-generated-artifacts.sh

---

## Build, inspect, and stage one example

To reduce copy/paste risk, use:

    ./scripts/build-inspect-stage-example.sh <example-name>

Example:

    ./scripts/build-inspect-stage-example.sh logos-logging-test

This script:

- cleans generated artifacts
- sets up Theos wrappers
- rebuilds Mach-O stubs
- builds the selected example
- inspects the produced `.deb`
- copies the exact inspected `.deb` to `/mnt/c/iPhone4sPush`
- writes a small manifest beside the staged package

It does **not** install anything on a device.

---

## Package inspection

Before any device install, inspect the `.deb` on the host:

    ./scripts/inspect-deb-package.sh path/to/package.deb

The first install candidate should always be harmless and reversible.

Expected safe package traits:

- only expected MobileSubstrate dylib/plist payload
- no maintainer scripts
- no LaunchDaemons
- no unexpected system paths
- no behavior-changing logic unless deliberately scoped and reviewed

---

## Device safety

Before touching a real device, read:

- `docs/DEVICE_INSTALL_SAFETY_PLAN.md`
- `docs/DEVICE_TRANSFER_WORKFLOW.md`
- `docs/NOOP_RUNTIME_VALIDATION.md`
- `docs/LOGOS_RUNTIME_VALIDATION_PLAN.md`
- `docs/LOGOS_RUNTIME_VALIDATION.md`
- `docs/LOGOS_LOGGING_VALIDATION.md`

Validated private/local Lane A device milestones:

- NoOpTweak install/file-placement/uninstall
- NoOpTweak controlled respring/runtime tolerance
- LogosHookTest controlled SpringBoard runtime lifecycle
- LogosLoggingTest hook-body marker creation
- marker cleanup
- final clean state

Do not treat these results as proof that arbitrary hooks are safe.

---

## WSL appliance preservation

Private full WSL appliance docs:

- `docs/WSL_APPLIANCE_EXPORT.md`
- `docs/APPLIANCE_MANIFEST.md`

Public toolchain-only appliance docs:

- `docs/PUBLIC_APPLIANCE.md`
- `docs/PUBLIC_HYDRATION_GUIDE.md`

The private full WSL appliance is a known-good operational environment and should not be published.

The public appliance is intentionally sanitized and toolchain-only.

---

## Public release distribution

The public `.tar` appliance may be too large for Gitea release attachments on some instances.

For this project, the `.tar` is static-hosted and release notes point to it.

Static appliance URL:

    https://git.bitcrusher32.win/downloads/legacy-ios-toolchain/V2.28/legacy-ios-toolchain-public-toolchain-V2.28.tar

Release sidecars:

- `legacy-ios-toolchain-public-toolchain-V2.28.sha256.txt`
- `legacy-ios-toolchain-public-toolchain-V2.28.manifest.txt`

Do not commit appliance `.tar` files to Git.

---

## Current non-goals

This repo is not currently trying to provide:

- Apple SDK redistribution
- a bundled full Theos/iPhoneOS SDK environment
- broad iOS compatibility claims
- arbitrary device support
- behavior-changing tweak examples
- production jailbreak tweak logic
- system-wide runtime modification examples

Historical references to older application-specific goals may exist in obsolete or preservation-scope docs, but they do not define the active project scope.

---

## Potential next work

Reasonable future branches:

1. public appliance import testing on a second machine
2. public hydration guide testing with a user-provided Theos/SDK setup
3. target matrix research without support claims
4. intensive host-side edge-case testing
5. additional package-shape checks
6. additional host-only SDK/framework symbol tests
7. optional public download landing page with checksum/manifest links
8. separate repo/project for actual tweak experiments

The repo is currently at a clean stopping point after the V2.29 public release appliance milestone.

License: MIT. See the repo's LICENSE file for more information.
