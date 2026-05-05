# Legacy iOS Toolchain for WSL Ubuntu 24.04

Patched build notes and verification scripts for getting Tidal-Loop/linux-ios-toolchain working on WSL Ubuntu 24.04.

Author: Bitcrusher32

## Status

Working baseline achieved.

Validated:
- Toolchain builds on WSL Ubuntu 24.04.3
- sudo make install installs tools into /usr/bin
- arm-apple-darwin-as emits Mach-O ARMv7 objects
- arm-apple-darwin-ld emits Mach-O ARMv7 relocatable objects
- arm-apple-darwin-ar creates valid archives
- ldid installs into PATH

Not yet validated:
- Full iOS executable linking
- SDK/libSystem path setup
- Theos tweak build
- .deb packaging
- Device install workflow

## Validated environment

Host:
- Windows 11 + WSL
- Ubuntu 24.04.3 LTS

Target context:
- ARMv7 legacy iOS
- iPhone 4s / iOS 6.1.3 (tested context)

Compatibility with other devices/versions is unverified.

## Base project

https://github.com/Tidal-Loop/linux-ios-toolchain

## Quick verify

Run:

    ./scripts/verify-toolchain.sh


## Reproducible build status

Current automation level:

1. Install dependencies:
       ./scripts/install-deps-ubuntu-24.04.sh

2. Clone/build/install helper:
       ./scripts/build-toolchain.sh

Important: patch application is not automated yet.

Before a fresh build succeeds, the source fixes described in PATCHES.md still need to be applied manually or converted into patch files under `patches/`.

## Reproducible build validation

Fresh reproducible build/install has been validated using a throwaway WSL workdir.

Validated flow:
- clone this repo
- clone Tidal-Loop/linux-ios-toolchain through build-toolchain.sh
- initialize submodules
- apply Linux/WSL compatibility patcher
- run ./configure arm-apple-darwin
- build cctools + ios tools
- install to /usr/bin
- run ARMv7 Mach-O smoke verification

Validated smoke outputs:
- test.o: Mach-O armv7 object
- test_reloc.o: Mach-O armv7 object
- libtest.a: current ar archive random library

Known remaining scope:
- full iOS executable linking is not validated
- Theos tweak build is not validated
- .deb packaging is not validated
- device install/uninstall is not validated

## Theos wrapper setup

After the legacy toolchain is installed, Theos may still expect iPhone compiler tools under:

    $THEOS/toolchain/linux/iphone/bin

Run:

    ./scripts/setup-theos-toolchain-links.sh

This installs wrapper scripts/symlinks for:
- clang
- clang++
- ar
- ld
- strip
- ranlib
- ldid
- codesign_allocate

Current caveat:
The wrapper setup is enough to reach no-op ARMv7 dylib emission and signing experiments, but real Objective-C/Foundation linking is not solved yet when using modern `.tbd`-based SDKs with old ld64.

## No-op Theos package milestone

A clean no-op Theos tweak has been compiled, signed, staged, and packaged as a `.deb` on the host.

Validated:
- ARMv7 tweak object compilation
- Darwin linker handoff through Theos wrappers
- ldid signing through wrapper that unsets `CODESIGN_ALLOCATE`
- `.deb` package creation

Major caveat:
This no-op package used a temporary `.tbd` overlay hack. Old `ld64` still ignores `.tbd` text stubs masquerading as `.dylib`/framework files. The package proves the host-side package pipeline, not real Objective-C/Foundation/Substrate linking correctness.

## Mach-O SDK stubs

Modern iPhoneOS SDKs provide `.tbd` text-based stubs. The recovered legacy `arm-apple-darwin-ld` does not consume these directly.

A temporary no-op `.tbd` overlay can prove package mechanics, but real Objective-C references require real Mach-O stubs.

Generate the currently validated minimal stubs with:

    ./scripts/build-ios-machostubs.sh

Validated so far:
- `libobjc.dylib` exporting `_objc_getClass`
- `libSystem.dylib` exporting `dyld_stub_binder`

These are linker stubs only. They are not runtime implementations and are not yet enough for Foundation/CoreFoundation/Substrate-heavy tweaks.

## CoreFoundation stub milestone

A minimal CoreFoundation test package has been validated using a real Mach-O framework stub.

Validated:
- `CFStringCreateWithCString`
- `kCFAllocatorDefault`
- ARMv7 tweak compile/link/sign/package flow

Framework-stub rule:
When a generated stub framework is placed early in `-F` search paths, it must include:
- the Mach-O binary, e.g. `CoreFoundation.framework/CoreFoundation`
- a `Headers` symlink back to the real SDK headers

Otherwise Clang may resolve the stub framework first and fail during header lookup.

## Foundation stub milestone

A minimal Foundation test package has been validated using a real Mach-O framework stub.

Validated:
- `NSClassFromString(@"NSObject")`
- ARMv7 tweak compile/link/sign/package flow

Additional wrapper suppressions required for old SDK headers under modern Clang:
- `-Wno-nullability-inferred-on-nested-type`
- `-Wno-nullability-completeness-on-arrays`
- `-Wno-nullability-completeness`

Current caveat:
The generated stubs are host-side linker aids only. They are not runtime framework implementations.
