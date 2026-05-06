# Logos Runtime Validation

This document records the first successful generated Logos/MobileSubstrate runtime lifecycle on the real target device.

## Scope

Package:

    com.bitcrusher32.logoshooktest

Device lane:

    iPhone 4s
    iOS 6.1.3
    ARMv7
    Cydia / MobileSubstrate
    SpringBoard target

This was a minimal Logos hook validation test.

It did not include application-specific behavior.

## Source

The validated hook:

    %hook SpringBoard

    - (void)applicationDidFinishLaunching:(id)application {
        %orig;
    }

    %end

The package filter targeted:

    com.apple.springboard

## Host inspection result

The package inspected cleanly before install.

Package metadata:

    Package: com.bitcrusher32.logoshooktest
    Name: LogosHookTest
    Depends: mobilesubstrate
    Architecture: iphoneos-arm
    Version: 0.0.1-1+debug

Payload:

    /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.dylib
    /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.plist

Safety checks:

- no red-flag paths
- no maintainer scripts
- no LaunchDaemons
- no preference bundles
- no unexpected payload files

Mach-O load commands included:

    /usr/lib/libobjc.A.dylib
    /System/Library/Frameworks/Foundation.framework/Foundation
    /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
    /usr/lib/libSystem.B.dylib
    /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate

Expected runtime-resolved symbols included:

    _MSHookMessageEx
    _objc_getClass
    dyld_stub_binder

## Transfer path

Known-good transfer/control chain:

    WSL build
    -> /mnt/c/iPhone4sPush/
    -> Windows PowerShell pscp.exe
    -> iPhone /var/root/
    -> PuTTY root shell
    -> dpkg install/remove/checks

## Install result

Device command:

    dpkg -i /var/root/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

Installed package check showed:

    ii  com.bitcrusher32.logoshooktest  0.0.1-1+debug  iphoneos-arm

File placement showed:

    /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.dylib
    /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.plist

## Runtime/respring result

Command:

    killall SpringBoard

Observed physical behavior:

    screen went black
    startup sound occurred
    Apple logo appeared
    device loaded to unlock screen
    user unlocked normally

No reported:

- boot loop
- stuck Apple logo
- Safe Mode alert
- visible instability

Post-respring checks showed:

- package remained installed
- `LogosHookTest.dylib` remained present
- `LogosHookTest.plist` remained present

## Uninstall result

Device command:

    dpkg -r com.bitcrusher32.logoshooktest

After uninstall:

    dpkg -l | grep -i bitcrusher32

returned no package, and:

    ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i LogosHookTest

returned no files.

The copied package was also removed from `/var/root/`.

## Post-uninstall respring

Command:

    killall SpringBoard

Final checks after post-uninstall respring showed:

- no `bitcrusher32` package listed
- no `LogosHookTest` files listed

## What this proves

This proves the current Lane A can support a generated Logos/MobileSubstrate package through:

- host build
- package inspection
- transfer
- dpkg install
- MobileSubstrate file placement
- controlled SpringBoard runtime loading
- normal device return
- uninstall
- post-uninstall clean state

## What this does not prove

This does not prove:

- arbitrary hook safety
- behavior-changing hooks
- noisy logging loops
- daemon hooks
- preference bundles
- other iOS versions
- other architectures
- other devices

## Next boundary

The next safe edge case is a logging-only hook with a clear, minimal, reversible observability mechanism.

Do not add behavior-changing examples yet.
