# Public Toolchain Appliance

This document describes the sanitized public toolchain-only WSL/rootfs-style appliance.

## Artifact

Filename:

    legacy-ios-toolchain-public-toolchain-V2.28.tar

Scope:

    toolchain-only sanitized public appliance

Validated:

- imported into a clean WSL distro
- `/PUBLIC_APPLIANCE_README.txt` present
- `/PUBLIC_APPLIANCE_MANIFEST.txt` present
- `./scripts/verify-toolchain.sh` passed
- ARMv7 Mach-O assembly smoke test passed
- ARMv7 relocatable linker smoke test passed
- ARM archive smoke test passed
- `ldid` present

Not included:

- Apple iPhoneOS SDKs
- private WSL user environment
- SSH keys
- shell history
- device credentials
- private device backups
- private full V2.27 appliance contents

Not validated in this public appliance:

- Theos package pipeline
- iPhoneOS SDK header/framework builds
- MobileSubstrate runtime tests
- device install/respring tests

For full Theos package validation, users must provide their own legally obtained SDK and configure Theos separately.

## Import example

PowerShell:

    New-Item -ItemType Directory -Force -Path C:\WSL-Imports\LegacyIOSToolchain-Public
    wsl --import LegacyIOSToolchain-Public C:\WSL-Imports\LegacyIOSToolchain-Public C:\Path\To\legacy-ios-toolchain-public-toolchain-V2.28.tar --version 2
    wsl -d LegacyIOSToolchain-Public

Inside the imported distro:

    cat /PUBLIC_APPLIANCE_README.txt
    cat /PUBLIC_APPLIANCE_MANIFEST.txt
    cd /opt/legacy-ios-toolchain-wsl
    ./scripts/verify-toolchain.sh

## Integrity

Release assets should include:

- `legacy-ios-toolchain-public-toolchain-V2.28.tar`
- `legacy-ios-toolchain-public-toolchain-V2.28.sha256.txt`
- `legacy-ios-toolchain-public-toolchain-V2.28.manifest.txt`

## Public artifact boundary

This appliance is intended to preserve the recovered toolchain state, not to redistribute Apple SDKs.

The public package pipeline remains a hydration task:

1. import the public appliance
2. obtain Apple SDKs through legitimate channels
3. configure Theos/SDK paths locally
4. run the repo validation scripts appropriate to that local setup
