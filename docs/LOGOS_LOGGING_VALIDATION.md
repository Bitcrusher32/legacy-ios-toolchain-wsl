# Logos Logging Validation

This document records the first successful generated Logos hook-body observability test on the real target device.

## Scope

Package:

    com.bitcrusher32.logosloggingtest

Device lane:

    iPhone 4s
    iOS 6.1.3
    ARMv7
    Cydia / MobileSubstrate
    SpringBoard target

This test proves a generated Logos hook body executed on-device by writing a tiny marker file.

It does not add behavior-changing tweak logic.

## Source behavior

The hook targets:

    SpringBoard applicationDidFinishLaunching:

The hook calls `%orig` first, then appends a marker line to:

    /var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt

The final implementation uses POSIX file I/O:

    open
    write
    close

Foundation/NSString file writing was intentionally avoided because it widened the Objective-C runtime symbol surface.

## Host build notes

The logging test required expanding the host-side libSystem Mach-O stub with:

    _open
    _write
    _close

These are host linker shim symbols only. The device provides the real libSystem at runtime.

## Package inspection

The inspected package contained only:

    /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.dylib
    /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.plist

Safety checks:

- no red-flag paths
- no maintainer scripts
- no LaunchDaemons
- no preference bundles
- no unexpected payload files

Expected runtime-resolved symbols included:

    _MSHookMessageEx
    _objc_getClass
    _open
    _write
    _close
    dyld_stub_binder

## Device runtime result

Before respring, the marker file was absent.

After controlled SpringBoard respring, the marker existed:

    /var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt

Observed marker content:

    LogosLoggingTest marker: SpringBoard applicationDidFinishLaunching executed.

Physical device behavior:

    screen went dark
    startup sound played
    Apple boot logo appeared
    device returned to login/lock screen

No reported:

- boot loop
- stuck Apple logo
- Safe Mode alert
- visible instability

## Cleanup result

After validation:

- package was uninstalled
- dylib/plist were removed
- marker file was removed
- copied .deb was removed
- post-uninstall respring completed
- final checks were clean

## What this proves

This proves the current primary lane supports:

- generated Logos package build
- package inspection
- device install
- MobileSubstrate file placement
- controlled SpringBoard runtime load
- actual hook-body execution
- observable marker creation
- clean uninstall and cleanup

## What this does not prove

This does not prove:

- behavior-changing hook safety
- broad system hooks
- daemon hooks
- preference bundles
- other target processes
- other devices
- other iOS versions
- other architectures
