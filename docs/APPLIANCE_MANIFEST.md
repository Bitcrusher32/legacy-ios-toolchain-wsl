# Appliance Manifest

This manifest records the known-good environment for the legacy iOS ARMv7 WSL toolchain appliance.

Update this file after running the host validation pipeline and before exporting the WSL distro.

## Manifest version

- LogDoc scope: V1.21
- Appliance label: legacy-ios-toolchain-wsl-V1.21
- Status: TEMPLATE / FILL BEFORE FINAL EXPORT

## Host machine

- Host OS: Windows 11
- WSL distro name:
- WSL distro version:
- Export date:
- Export operator: bitcrusher32

## Ubuntu / WSL environment

Fill using:

    cat /etc/os-release
    uname -a
    whoami
    pwd

Recorded values:

    PRETTY_NAME=
    VERSION_ID=
    VERSION_CODENAME=
    kernel=
    user=
    home=

## Repository

Fill using:

    cd ~/legacy-ios-toolchain-wsl
    git remote -v
    git branch --show-current
    git rev-parse HEAD
    git status --short

Recorded values:

    repo_path=~/legacy-ios-toolchain-wsl
    remote=
    branch=
    commit=
    working_tree_status=

Expected working tree before export:

    clean, or only intentionally untracked local logs

## Toolchain source/build path

Recorded values:

    toolchain_source_path=~/linux-ios-toolchain
    controller_repo_path=~/legacy-ios-toolchain-wsl

## Installed toolchain binaries

Fill using:

    which arm-apple-darwin-ar
    which arm-apple-darwin-ld
    which arm-apple-darwin-as
    which ldid
    arm-apple-darwin-ld -v 2>&1 | head -5

Recorded values:

    arm-apple-darwin-ar=
    arm-apple-darwin-ld=
    arm-apple-darwin-as=
    ldid=
    arm-apple-darwin-ld_version=

## Theos

Fill using:

    echo "$THEOS"
    ls -la ~/theos | head
    find ~/theos/sdks -maxdepth 1 -type d -name 'iPhoneOS*.sdk' | sort

Recorded values:

    THEOS=
    theos_path=~/theos
    sdks_present=
    primary_sdk=iPhoneOS9.3.sdk
    target=iphone:clang:9.3:6.1
    arch=armv7

## Theos wrapper paths

Fill using:

    ls -la "$THEOS/toolchain/linux/iphone/bin"
    sed -n '1,140p' "$THEOS/toolchain/linux/iphone/bin/clang"
    sed -n '1,160p' "$THEOS/toolchain/linux/iphone/bin/clang++"
    sed -n '1,80p' "$THEOS/toolchain/linux/iphone/bin/ldid"

Recorded values:

    wrapper_bin=$THEOS/toolchain/linux/iphone/bin
    clang_wrapper=
    clangxx_wrapper=
    ldid_wrapper=

Required wrapper behavior:

- `clang` and `clang++` return a version for `-dumpversion`.
- wrappers pass `-B"$THEOS/toolchain/linux/iphone/bin"` for Darwin linker discovery.
- wrappers strip incompatible modules flags.
- wrappers suppress old SDK nullability warnings.
- wrappers include early Mach-O stub paths:
  - `$HOME/ios-sdk-machostubs/iPhoneOS9.3/usr/lib`
  - `$HOME/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks`
  - `$HOME/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks`
- `ldid` wrapper unsets `CODESIGN_ALLOCATE`.

## Mach-O stub root

Fill using:

    find ~/ios-sdk-machostubs/iPhoneOS9.3 -maxdepth 6 \( -type f -o -type l \) | sort

Recorded values:

    machostub_root=~/ios-sdk-machostubs/iPhoneOS9.3

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

Fill using:

    cd ~/legacy-ios-toolchain-wsl
    ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-appliance.log
    find examples -path '*/packages/*.deb' -type f -ls

Recorded values:

    validation_date=
    validation_result=
    validation_log=

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

    source_distro=
    export_path=C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
    export_size=
    sha256=

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
    restore_test_date=
    restore_validation_result=
    restore_validation_log=

## Safety boundary

This appliance proves host-side build/package reproducibility only.

It does not prove package install safety, SpringBoard runtime behavior, MobileSubstrate runtime behavior, GPS spoof logic, or uninstall/recovery safety.

No device install should be performed until `docs/DEVICE_INSTALL_SAFETY_PLAN.md` exists and has been reviewed.
