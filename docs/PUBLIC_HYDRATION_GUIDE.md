# Public Appliance Hydration Guide

The public appliance is intentionally toolchain-only.

It contains:

- rebuilt legacy ARMv7 iOS toolchain binaries
- repository source snapshot
- smoke-test validation scripts
- public appliance metadata

It does not contain:

- Apple iPhoneOS SDKs
- Theos SDK payloads
- private WSL user data
- SSH keys
- shell history
- device credentials
- private device backups
- private full development appliance contents

## Import the public appliance

PowerShell:

    New-Item -ItemType Directory -Force -Path C:\WSL-Imports\LegacyIOSToolchain-Public

    wsl --import LegacyIOSToolchain-Public `
      C:\WSL-Imports\LegacyIOSToolchain-Public `
      C:\Path\To\legacy-ios-toolchain-public-toolchain-V2.28.tar `
      --version 2

    wsl -d LegacyIOSToolchain-Public

Inside the imported distro:

    cat /PUBLIC_APPLIANCE_README.txt
    cat /PUBLIC_APPLIANCE_MANIFEST.txt

    cd /opt/legacy-ios-toolchain-wsl
    ./scripts/verify-toolchain.sh

## What should pass immediately

The public appliance should pass:

    ./scripts/verify-toolchain.sh

This verifies:

- `arm-apple-darwin-as`
- `arm-apple-darwin-ld`
- `arm-apple-darwin-ar`
- `ldid`
- ARMv7 Mach-O object assembly
- ARMv7 relocatable Mach-O linking
- archive creation

## Hydrating Theos and SDK support

The public appliance does not redistribute Apple SDKs.

For Theos package validation, users must provide their own legally obtained SDKs and configure Theos locally.

Expected local-only setup steps:

1. install or provide Theos
2. provide a legally obtained iPhoneOS SDK
3. set `THEOS` appropriately
4. run:

       ./scripts/setup-theos-toolchain-links.sh
       ./scripts/build-ios-machostubs.sh

5. then try host-only validation examples as appropriate

## What not to claim

Do not claim the public appliance validates:

- Theos package generation
- Apple SDK header/framework builds
- MobileSubstrate runtime behavior
- device install/respring behavior
- arbitrary iOS versions
- arbitrary devices or architectures

Those validations belong to separately documented local/private lanes.

## Public artifact boundary

The public appliance exists to preserve and demonstrate the recovered legacy ARMv7 toolchain.

The full private development environment remains separate because it may contain local SDKs, device workflow details, and other private machine state.
