# WSL Appliance Export / Import

This document describes how to preserve the known-good legacy iOS ARMv7 toolchain environment as a WSL appliance.

The Git repository is the reproducible recipe. The WSL export is the preserved known-good appliance.

## Why WSL export first?

This project is already validated under WSL Ubuntu. The working environment depends on Ubuntu package state, installed arm-apple-darwin tools, Theos, iPhoneOS SDK folders, wrapper scripts, generated Mach-O linker stubs, and generated framework header symlinks.

A WSL distro export preserves the whole Linux userspace as-is. Docker may still be useful later, but it can introduce extra differences in paths, filesystem behavior, permissions, init assumptions, and nested toolchain behavior.

## Before export

Inside WSL, run:

    cd ~/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-appliance.log
    find examples -path '*/packages/*.deb' -type f -ls

Confirm the log ends with:

    Host pipeline validation complete.

Recommended cleanup before export:

    cd ~/legacy-ios-toolchain-wsl
    find examples -type d \( -name .theos -o -name packages \) -prune -exec rm -rf {} +
    rm -f validate-host-pipeline-*.log

Do not delete:

    ~/theos
    ~/ios-sdk-machostubs
    ~/linux-ios-toolchain
    ~/legacy-ios-toolchain-wsl

## Export from Windows PowerShell

Run from Windows PowerShell, not inside WSL.

List distros:

    wsl --list --verbose

Shut WSL down cleanly:

    wsl --shutdown

Create backup folder:

    New-Item -ItemType Directory -Force -Path C:\WSL-Backups

Export the current Ubuntu distro. Replace `Ubuntu` with the actual distro name if needed:

    wsl --export Ubuntu C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar

Generate checksum:

    Get-FileHash C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar -Algorithm SHA256

Record the SHA256 in:

    docs/APPLIANCE_MANIFEST.md

## Import / restore test

Run from Windows PowerShell.

Create target folder:

    New-Item -ItemType Directory -Force -Path C:\WSL\LegacyIOSToolchain-V1.21

Import under a new distro name:

    wsl --import LegacyIOSToolchain-V1.21 C:\WSL\LegacyIOSToolchain-V1.21 C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar

Launch restored distro:

    wsl -d LegacyIOSToolchain-V1.21

Inside the restored distro, run:

    cd ~/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-restored.log

If that passes, the appliance export is validated.

## Safety notes

This appliance validates host-side build/package behavior only. It does not prove device runtime safety.

Do not install packages on the iPhone until a separate harmless install/uninstall plan is written and reviewed.

## Current validated host ladder

The appliance should validate:

1. Toolchain smoke verification
2. Theos wrapper setup
3. Mach-O SDK stub generation
4. no-op tweak package
5. Objective-C runtime package
6. CoreFoundation package
7. Foundation package
8. Logos/MobileSubstrate hook package

## Known non-goals

This appliance does not yet validate device install, device uninstall, SpringBoard runtime behavior, GPS spoofing, preferences UI, or recovery from a bad tweak.
