# Logos Runtime Validation Plan

This is the next device-side milestone after NoOpTweak runtime validation.

Goal:

    prove a generated Logos/MobileSubstrate package can load on-device,
    survive a controlled SpringBoard respring,
    and uninstall cleanly.

Status: completed for LogosHookTest on the iPhone 4s / iOS 6.1.3 / ARMv7 lane. See docs/LOGOS_RUNTIME_VALIDATION.md.

This still does not include FakeGPS logic.

## Candidate package

    examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

## Pre-install host checks

Run from WSL:

    cd ~/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh
    ./scripts/inspect-deb-package.sh examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

Confirm:

- package id is expected
- architecture is iphoneos-arm
- payload only installs under `/Library/MobileSubstrate/DynamicLibraries/`
- no LaunchDaemons
- no PreferenceBundles
- no maintainer scripts unless intentionally added
- load commands include expected system libraries/frameworks
- CydiaSubstrate load command is present or symbols are resolved as expected

## Transfer path

Use the known-good path:

    WSL -> /mnt/c/iPhone4sPush/ -> PowerShell pscp.exe -> /var/root/ -> PuTTY dpkg

Do not use WSL SSH/SCP as the default transfer path yet.

## Install test

On device through PuTTY:

    dpkg -i /var/root/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

Then check:

    dpkg -l | grep -i bitcrusher32 || true
    ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i LogosHookTest || true

Stop if anything looks wrong.

## Controlled respring

On device through PuTTY:

    killall SpringBoard

Physically confirm:

- device returns to lock screen or home screen
- no boot loop
- no Safe Mode alert
- PuTTY can reconnect

Then check:

    dpkg -l | grep -i bitcrusher32 || true
    ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i LogosHookTest || true

## Uninstall and post-uninstall respring

On device through PuTTY:

    dpkg -r com.bitcrusher32.logoshooktest
    rm -f /var/root/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
    killall SpringBoard

Final checks:

    dpkg -l | grep -i bitcrusher32 || true
    ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i LogosHookTest || true

## Stop conditions

Stop immediately if:

- SpringBoard loops
- Safe Mode appears
- SSH/PuTTY becomes unreliable
- package removal fails
- files remain after uninstall
- device behavior looks abnormal

## After success

LogosHookTest succeeded. The next milestone can be a logging-only hook with a clear verification method.

Still do not start GPS spoofing until a logging-only hook is validated.
