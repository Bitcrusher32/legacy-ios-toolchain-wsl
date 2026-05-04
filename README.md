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

