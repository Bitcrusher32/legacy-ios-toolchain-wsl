# Appliance Manifest

This manifest records the known-good environment for the legacy iOS ARMv7 WSL toolchain appliance.

Generated/updated by:

    scripts/update-appliance-manifest.sh

## Manifest version

- LogDoc scope: V1.21
- Appliance label: legacy-ios-toolchain-wsl-V1.21
- Status: HOST VALIDATION PASSED / READY FOR WSL EXPORT
- Snapshot timestamp UTC: 2026-05-05T18:19:28Z

## Host machine

- Host OS: Windows 11
- WSL distro name: Ubuntu
- WSL distro version: 2
- Export date: 2026-05-05T18:27:47Z
- Export operator: bitcrusher32

## Ubuntu / WSL environment

Recorded values:

    PRETTY_NAME=Ubuntu 24.04.3 LTS
    VERSION_ID=24.04
    VERSION_CODENAME=noble
    kernel=Linux PIXELASPIRE96 6.6.87.2-microsoft-standard-WSL2 #1 SMP PREEMPT_DYNAMIC Thu Jun  5 18:30:46 UTC 2025 x86_64 x86_64 x86_64 GNU/Linux
    user=bitcrusher32
    home=/home/bitcrusher32

## Repository

Recorded values:

    repo_path=/home/bitcrusher32/legacy-ios-toolchain-wsl
    branch=main
    commit=b8ca12079758ec873644d1ac1096deaff7959168
    working_tree_status=dirty_or_untracked

Remote:

    origin https://git.bitcrusher32.win/bitcrusher32/theros-monumental-wsl-toolkit.git (fetch)
    origin https://git.bitcrusher32.win/bitcrusher32/theros-monumental-wsl-toolkit.git (push)

Git status --short at snapshot time:

    ?? scripts/update-appliance-manifest.sh

Expected working tree before final export:

    clean, or only intentionally untracked local logs

## Toolchain source/build path

Recorded values:

    toolchain_source_path=/home/bitcrusher32/linux-ios-toolchain
    controller_repo_path=/home/bitcrusher32/legacy-ios-toolchain-wsl

## Installed toolchain binaries

Recorded values:

    arm-apple-darwin-ar=/usr/bin/arm-apple-darwin-ar
    arm-apple-darwin-ld=/usr/bin/arm-apple-darwin-ld
    arm-apple-darwin-as=/usr/bin/arm-apple-darwin-as
    ldid=/usr/bin/ldid

arm-apple-darwin-ld version output:

    241.9
    configured to support archs: armv4t armv5 armv6 armv7 armv7f armv7k armv7s armv6m armv7m armv7em armv8 arm64 arm64v8 i386 x86_64 x86_64h
    LTO support using: LLVM version 18.1.3

## Theos

Recorded values:

    THEOS=/home/bitcrusher32/theos
    theos_path=/home/bitcrusher32/theos
    sdks_present=iPhoneOS10.3.sdk iPhoneOS11.4.sdk iPhoneOS12.4.sdk iPhoneOS13.7.sdk iPhoneOS14.5.sdk iPhoneOS15.6.sdk iPhoneOS16.5.sdk iPhoneOS9.3.sdk 
    primary_sdk=iPhoneOS9.3.sdk
    target=iphone:clang:9.3:6.1
    arch=armv7

## Theos wrapper paths

Recorded values:

    wrapper_bin=/home/bitcrusher32/theos/toolchain/linux/iphone/bin
    clang_wrapper=/home/bitcrusher32/theos/toolchain/linux/iphone/bin/clang
    clangxx_wrapper=/home/bitcrusher32/theos/toolchain/linux/iphone/bin/clang++
    ldid_wrapper=/home/bitcrusher32/theos/toolchain/linux/iphone/bin/ldid

Wrapper directory listing:

    total 44
    drwxr-xr-x 2 bitcrusher32 bitcrusher32 4096 May  5 13:51 .
    drwxr-xr-x 3 bitcrusher32 bitcrusher32 4096 May  3 05:03 ..
    lrwxrwxrwx 1 bitcrusher32 bitcrusher32   28 May  5 13:51 ar -> /usr/bin/arm-apple-darwin-ar
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  714 May  5 13:51 clang
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  765 May  5 13:51 clang++
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  497 May  5 12:23 clang++.pre-cf-machostub-path
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  564 May  5 12:35 clang++.pre-foundation-nullability-fix
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  448 May  5 12:00 clang++.pre-machostub-path
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  446 May  5 12:23 clang.pre-cf-machostub-path
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  513 May  5 12:35 clang.pre-foundation-nullability-fix
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32  130 May  5 13:51 codesign_allocate
    lrwxrwxrwx 1 bitcrusher32 bitcrusher32   28 May  5 13:51 ld -> /usr/bin/arm-apple-darwin-ld
    -rwxr-xr-x 1 bitcrusher32 bitcrusher32   68 May  5 13:51 ldid
    lrwxrwxrwx 1 bitcrusher32 bitcrusher32   32 May  5 13:51 ranlib -> /usr/bin/arm-apple-darwin-ranlib
    lrwxrwxrwx 1 bitcrusher32 bitcrusher32   31 May  5 13:51 strip -> /usr/bin/arm-apple-darwin-strip

Required wrapper behavior:

- clang and clang++ return a version for -dumpversion.
- wrappers pass -B for Darwin linker discovery.
- wrappers strip incompatible modules flags.
- wrappers suppress old SDK nullability warnings.
- wrappers include early Mach-O stub paths:
  - /home/bitcrusher32/ios-sdk-machostubs/iPhoneOS9.3/usr/lib
  - /home/bitcrusher32/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks
  - /home/bitcrusher32/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks
- ldid wrapper unsets CODESIGN_ALLOCATE.

## Mach-O stub root

Recorded values:

    machostub_root=/home/bitcrusher32/ios-sdk-machostubs/iPhoneOS9.3

Generated stubs currently present:

    ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
    ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate_stub.o
    ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate_stub.s
    ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks/CydiaSubstrate.framework/Headers
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation_stub.o
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation_stub.s
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/CoreFoundation.framework/Headers
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/Foundation.framework/Foundation
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/Foundation.framework/Foundation_stub.o
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/Foundation.framework/Foundation_stub.s
    ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/Foundation.framework/Headers
    ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libSystem.dylib
    ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libSystem_stub.o
    ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libSystem_stub.s
    ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libobjc.dylib
    ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libobjc_stub.o
    ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libobjc_stub.s

Expected generated stubs:

    usr/lib/libobjc.dylib
    usr/lib/libSystem.dylib
    System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
    System/Library/Frameworks/CoreFoundation.framework/Headers -> real SDK Headers
    System/Library/Frameworks/Foundation.framework/Foundation
    System/Library/Frameworks/Foundation.framework/Headers -> real SDK Headers
    Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
    Library/Frameworks/CydiaSubstrate.framework/Headers -> real Theos vendor Headers

Expected exported symbols:

    libobjc.dylib:
      _objc_getClass

    libSystem.dylib:
      dyld_stub_binder

    CoreFoundation.framework/CoreFoundation:
      _CFStringCreateWithCString
      _kCFAllocatorDefault

    Foundation.framework/Foundation:
      _NSClassFromString
      ___CFConstantStringClassReference

    CydiaSubstrate.framework/CydiaSubstrate:
      _MSHookMessageEx
      _MSHookFunction

## Host validation pipeline

Recorded values:

    validation_date=2026-05-05T18:19:47Z
    validation_result=PASS_HOST_PIPELINE
    validation_log=validate-host-pipeline-appliance.log

Expected command:

    cd /home/bitcrusher32/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-appliance.log
    find examples -path '*/packages/*.deb' -type f -ls

Expected package outputs:

    examples/noop-tweak/packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb
    examples/objc-runtime-test/packages/com.bitcrusher32.objcruntimetest_0.0.1-1+debug_iphoneos-arm.deb
    examples/corefoundation-test/packages/com.bitcrusher32.corefoundationtest_0.0.1-1+debug_iphoneos-arm.deb
    examples/foundation-test/packages/com.bitcrusher32.foundationtest_0.0.1-1+debug_iphoneos-arm.deb
    examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

## WSL export

Fill after exporting from PowerShell.

PowerShell commands:

    wsl --list --verbose
    wsl --shutdown
    New-Item -ItemType Directory -Force -Path C:\WSL-Backups
    wsl --export Ubuntu C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
    Get-FileHash C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar -Algorithm SHA256

Recorded values:

    source_distro=Ubuntu
    export_path=C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
    export_size=5689487360 bytes
    sha256=781764A4DFA80340E8FD18C162A10B23658A4AB807DEF9301B84C4EC8DC123D8

## Restore test

Fill after import testing.

PowerShell commands:

    New-Item -ItemType Directory -Force -Path C:\WSL\LegacyIOSToolchain-V1.21
    wsl --import LegacyIOSToolchain-V1.21 C:\WSL\LegacyIOSToolchain-V1.21 C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
    wsl -d LegacyIOSToolchain-V1.21

Inside restored WSL:

    cd ~/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-restored.log

Recorded values:

    restore_test_distro=LegacyIOSToolchain-V1.21
    restore_test_date=FILL_AFTER_RESTORE_TEST
    restore_validation_result=FILL_AFTER_RESTORE_TEST
    restore_validation_log=validate-host-pipeline-restored.log

## Safety boundary

This appliance proves host-side build/package reproducibility only.

It does not prove package install safety, SpringBoard runtime behavior, MobileSubstrate runtime behavior, GPS spoof logic, or uninstall/recovery safety.

No device install should be performed until docs/DEVICE_INSTALL_SAFETY_PLAN.md exists and has been reviewed.

## Export privacy warning

The WSL export tar is a private full-filesystem appliance image. Do not publish it publicly.

It may contain shell history, SSH material, Git credentials, private files, downloaded SDKs, device notes, usernames, local paths, and other sensitive host artifacts.

Recommended storage:

    local encrypted drive
    private offline backup
    private access-controlled storage only

Do not commit the export tar into Git.

