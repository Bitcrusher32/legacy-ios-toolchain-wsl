# Device Install Safety Plan

This document defines the safety protocol for the first on-device package install tests.

Current scope:

- iPhone 4s
- iOS 6.1.3
- jailbroken
- OpenSSH available
- MobileSubstrate installed
- host-side build/package pipeline validated
- no FakeGPS logic yet

## Hard rule

Do not install real FakeGPS logic until a harmless package install/uninstall has been tested.

The first device test must be either:

1. a no-op package, or
2. a logging-only package with a harmless SpringBoard hook

No GPS hooks, CoreLocation hooks, locationd hooks, daemon changes, or preference bundles should be tested in the first install.

## Current device preservation assumptions

The device is considered valuable and fragile.

Known concerns:

- imported iPhone 4s with unusual/China-only legacy apps
- 3uTools backup exists but restore reliability is not fully proven
- avoid iOS restore/update paths
- avoid packages that can bootloop SpringBoard
- avoid broad system hooks until recovery workflow is proven

## Pre-install checklist

Before installing any generated package:

- Confirm iPhone battery is charged.
- Confirm Windows hotspot or current network lets host reach the iPhone over SSH.
- Confirm SSH login works.
- Confirm root password is known.
- Strongly consider changing the root password away from `alpine` before repeated network testing.
- Confirm Cydia opens.
- Confirm MobileSubstrate is installed.
- Confirm Safe Mode package is installed.
- Confirm `/Library/MobileSubstrate/DynamicLibraries/` exists.
- Confirm `dpkg` works.
- Confirm package contents on the host using `scripts/inspect-deb-package.sh`.

## SSH/device checks

Run from host before install:

    ssh root@IPHONE_IP 'uname -a'
    ssh root@IPHONE_IP 'whoami'
    ssh root@IPHONE_IP 'dpkg -l | grep -Ei "substrate|safe|preferenceloader" || true'
    ssh root@IPHONE_IP 'ls -la /Library/MobileSubstrate/DynamicLibraries/'

Replace `IPHONE_IP` with the current iPhone IP address.

## Host package inspection

From WSL, inspect the package before copying it to the device:

    cd ~/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh
    ./scripts/inspect-deb-package.sh examples/noop-tweak/packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb

Confirm:

- package name is expected
- architecture is `iphoneos-arm`
- payload only places files under `/Library/MobileSubstrate/DynamicLibraries/`
- dylib name matches plist name
- no LaunchDaemons
- no preference bundles
- no binaries outside the expected MobileSubstrate path
- no maintainer scripts unless deliberately added
- no GPS/CoreLocation/locationd logic

## Recommended first package

Preferred first install candidate:

    examples/noop-tweak/packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb

Reason:

- simplest payload
- no intentional hook behavior
- validates package transfer, dpkg install, file placement, and removal

Second candidate only after no-op succeeds:

    examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

Reason:

- validates minimal MobileSubstrate/Logos runtime behavior
- hooks SpringBoard launch method and calls `%orig`
- still no GPS behavior

## Copy package to device

From WSL or Windows shell with SSH access:

    scp examples/noop-tweak/packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb root@IPHONE_IP:/var/root/

## Install package

On the device via SSH:

    ssh root@IPHONE_IP
    dpkg -i /var/root/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb

If dpkg reports dependency issues, stop and record the output.

Do not run random repair commands unless reviewed.

## Confirm install

After install:

    dpkg -l | grep -i bitcrusher32
    ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i NoOpTweak

Expected files:

    /Library/MobileSubstrate/DynamicLibraries/NoOpTweak.dylib
    /Library/MobileSubstrate/DynamicLibraries/NoOpTweak.plist

## Respring/restart behavior

For a no-op package, a respring may not be necessary to validate file placement, but MobileSubstrate loads tweaks into target processes after process restart.

Preferred cautious order:

1. Install package.
2. Confirm files are placed.
3. Remove package before respring if only testing dpkg/file placement.
4. Only later test runtime loading with a deliberate respring.

## Uninstall package

On device:

    dpkg -r com.bitcrusher32.nooptweak

Then verify:

    dpkg -l | grep -i bitcrusher32 || true
    ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i NoOpTweak || true

Expected:

- package no longer listed as installed
- NoOpTweak dylib/plist removed

## Emergency disable path

If a tweak causes issues but SSH still works:

    ssh root@IPHONE_IP
    mv /Library/MobileSubstrate/DynamicLibraries/PROBLEM.dylib /var/root/PROBLEM.dylib.disabled
    mv /Library/MobileSubstrate/DynamicLibraries/PROBLEM.plist /var/root/PROBLEM.plist.disabled
    reboot

For package removal:

    dpkg -r PACKAGE_ID

If SpringBoard is unstable but SSH works, disable the dylib/plist first, then reboot or respring.

## Stop conditions

Stop immediately if:

- SSH becomes unreliable
- Cydia or dpkg reports unexpected dependency changes
- package installs files outside expected paths
- package contains maintainer scripts not intentionally added
- SpringBoard crashes repeatedly
- device enters Safe Mode unexpectedly
- uninstall does not remove files cleanly

## What this test proves

A successful no-op install/uninstall proves:

- host can transfer package
- dpkg can install the generated package
- package payload paths are correct
- package can be removed
- basic recovery workflow is understood

It does not prove:

- Logos runtime hook safety
- CoreLocation spoofing
- locationd behavior
- system-wide spoofing
- preference bundle behavior
- long-term stability

## Next milestone after no-op install/uninstall

Only after no-op install/uninstall succeeds:

1. inspect LogosHookTest package
2. install LogosHookTest
3. respring intentionally
4. confirm no bootloop/Safe Mode
5. uninstall LogosHookTest
6. then consider first logging-only real hook experiment

FakeGPS logic should start only after these safety tests pass.
