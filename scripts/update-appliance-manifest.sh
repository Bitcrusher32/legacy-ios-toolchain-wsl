#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

export THEOS="${THEOS:-$HOME/theos}"

OUT="docs/APPLIANCE_MANIFEST.md"
TMP="$(mktemp)"

timestamp_utc="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
branch="$(git branch --show-current 2>/dev/null || true)"
commit="$(git rev-parse HEAD 2>/dev/null || true)"
status_short="$(git status --short 2>/dev/null || true)"
remote="$(git remote -v 2>/dev/null | sed 's/[[:space:]]\+/ /g' || true)"
kernel="$(uname -a)"
user_name="$(whoami)"
home_dir="$HOME"
ld_version="$(arm-apple-darwin-ld -v 2>&1 | head -5 || true)"
ubuntu_pretty="$(. /etc/os-release && echo "${PRETTY_NAME:-}")"
ubuntu_version_id="$(. /etc/os-release && echo "${VERSION_ID:-}")"
ubuntu_codename="$(. /etc/os-release && echo "${VERSION_CODENAME:-}")"

tool_ar="$(command -v arm-apple-darwin-ar || true)"
tool_ld="$(command -v arm-apple-darwin-ld || true)"
tool_as="$(command -v arm-apple-darwin-as || true)"
tool_ldid="$(command -v ldid || true)"

sdks_present="$(find "$THEOS/sdks" -maxdepth 1 -type d -name 'iPhoneOS*.sdk' 2>/dev/null | sort | sed "s|$THEOS/sdks/||" | tr '\n' ' ')"

wrapper_bin="$THEOS/toolchain/linux/iphone/bin"
machostub_root="$HOME/ios-sdk-machostubs/iPhoneOS9.3"

validation_log="validate-host-pipeline-appliance.log"
validation_result="NOT_RUN_IN_THIS_SCRIPT"

cat > "$TMP" <<DOC
# Appliance Manifest

This manifest records the known-good environment for the legacy iOS ARMv7 WSL toolchain appliance.

Generated/updated by:

    scripts/update-appliance-manifest.sh

## Manifest version

- LogDoc scope: V1.21
- Appliance label: legacy-ios-toolchain-wsl-V1.21
- Status: HOST SNAPSHOT GENERATED
- Snapshot timestamp UTC: $timestamp_utc

## Host machine

- Host OS: Windows 11
- WSL distro name: FILL FROM POWERSHELL: wsl --list --verbose
- WSL distro version: FILL FROM POWERSHELL
- Export date: FILL AFTER EXPORT
- Export operator: bitcrusher32

## Ubuntu / WSL environment

Recorded values:

    PRETTY_NAME=$ubuntu_pretty
    VERSION_ID=$ubuntu_version_id
    VERSION_CODENAME=$ubuntu_codename
    kernel=$kernel
    user=$user_name
    home=$home_dir

## Repository

Recorded values:

    repo_path=$REPO_ROOT
    branch=$branch
    commit=$commit
    working_tree_status=$(if [ -z "$status_short" ]; then echo "clean"; else echo "dirty_or_untracked"; fi)

Remote:

$(printf '%s\n' "$remote" | sed 's/^/    /')

Git status --short at snapshot time:

$(if [ -z "$status_short" ]; then echo "    clean"; else printf '%s\n' "$status_short" | sed 's/^/    /'; fi)

Expected working tree before final export:

    clean, or only intentionally untracked local logs

## Toolchain source/build path

Recorded values:

    toolchain_source_path=$HOME/linux-ios-toolchain
    controller_repo_path=$REPO_ROOT

## Installed toolchain binaries

Recorded values:

    arm-apple-darwin-ar=$tool_ar
    arm-apple-darwin-ld=$tool_ld
    arm-apple-darwin-as=$tool_as
    ldid=$tool_ldid

arm-apple-darwin-ld version output:

$(printf '%s\n' "$ld_version" | sed 's/^/    /')

## Theos

Recorded values:

    THEOS=$THEOS
    theos_path=$HOME/theos
    sdks_present=$sdks_present
    primary_sdk=iPhoneOS9.3.sdk
    target=iphone:clang:9.3:6.1
    arch=armv7

## Theos wrapper paths

Recorded values:

    wrapper_bin=$wrapper_bin
    clang_wrapper=$wrapper_bin/clang
    clangxx_wrapper=$wrapper_bin/clang++
    ldid_wrapper=$wrapper_bin/ldid

Wrapper directory listing:

$(ls -la "$wrapper_bin" 2>/dev/null | sed 's/^/    /' || true)

Required wrapper behavior:

- clang and clang++ return a version for -dumpversion.
- wrappers pass -B for Darwin linker discovery.
- wrappers strip incompatible modules flags.
- wrappers suppress old SDK nullability warnings.
- wrappers include early Mach-O stub paths:
  - $HOME/ios-sdk-machostubs/iPhoneOS9.3/usr/lib
  - $HOME/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks
  - $HOME/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks
- ldid wrapper unsets CODESIGN_ALLOCATE.

## Mach-O stub root

Recorded values:

    machostub_root=$machostub_root

Generated stubs currently present:

$(find "$machostub_root" -maxdepth 6 \( -type f -o -type l \) 2>/dev/null | sort | sed "s|$HOME/||" | sed 's/^/    /' || true)

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

    validation_date=FILL AFTER RUNNING VALIDATION
    validation_result=$validation_result
    validation_log=$validation_log

Expected command:

    cd $REPO_ROOT
    ./scripts/validate-host-pipeline.sh 2>&1 | tee $validation_log
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
    New-Item -ItemType Directory -Force -Path C:\\WSL-Backups
    wsl --export Ubuntu C:\\WSL-Backups\\legacy-ios-toolchain-wsl-V1.21.tar
    Get-FileHash C:\\WSL-Backups\\legacy-ios-toolchain-wsl-V1.21.tar -Algorithm SHA256

Recorded values:

    source_distro=FILL_FROM_POWERSHELL
    export_path=C:\\WSL-Backups\\legacy-ios-toolchain-wsl-V1.21.tar
    export_size=FILL_AFTER_EXPORT
    sha256=FILL_AFTER_EXPORT

## Restore test

Fill after import testing.

PowerShell commands:

    New-Item -ItemType Directory -Force -Path C:\\WSL\\LegacyIOSToolchain-V1.21
    wsl --import LegacyIOSToolchain-V1.21 C:\\WSL\\LegacyIOSToolchain-V1.21 C:\\WSL-Backups\\legacy-ios-toolchain-wsl-V1.21.tar
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
DOC

mv "$TMP" "$OUT"
echo "Updated $OUT"
