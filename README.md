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
