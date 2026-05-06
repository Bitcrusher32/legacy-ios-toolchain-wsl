# Edge-Case Testing Plan

This document tracks reusable toolchain and runtime edge cases.

The goal is to add minimal examples that prove compatibility behavior, not application features.

## Rules for new examples

Examples should be:

- minimal
- harmless
- reproducible
- narrowly scoped
- documented
- included in the validation pipeline only after stable

Examples should not be:

- product features
- device-risky behavior
- broad system hooks
- application-specific logic
- preference/UI experiments unless the edge case is specifically preference loading

## Existing examples

Current repo-hosted examples:

- `examples/noop-tweak`
- `examples/objc-runtime-test`
- `examples/corefoundation-test`
- `examples/foundation-test`
- `examples/logos-hook-test`

## Current edge cases already covered

### Toolchain smoke

Validated by:

- `scripts/verify-toolchain.sh`
- `examples/noop-asm/test.s`

Covers:

- ARMv7 assembly
- relocatable Mach-O link
- archive creation

### Theos no-op package

Validated by:

- `examples/noop-tweak`

Covers:

- Theos compile/link/package
- ldid signing
- MobileSubstrate file placement
- device install/uninstall
- controlled respring with generated dylib/plist present

### Objective-C runtime symbol

Validated by:

- `examples/objc-runtime-test`

Covers:

- `_objc_getClass`
- generated Mach-O `libobjc` stub
- generated Mach-O `libSystem` stub for `dyld_stub_binder`

### CoreFoundation symbol

Validated by:

- `examples/corefoundation-test`

Covers:

- CoreFoundation framework stub
- framework header symlink behavior

### Foundation symbol

Validated by:

- `examples/foundation-test`

Covers:

- Foundation framework stub
- Objective-C/Foundation header compatibility
- nullability warning suppression in wrappers

### Logos/MobileSubstrate host package

Validated host-side by:

- `examples/logos-hook-test`

Covers:

- Logos preprocessing
- CydiaSubstrate framework stub
- host package generation

Device runtime validation has now passed for the minimal LogosHookTest lifecycle.

## Candidate future edge cases

Add only as needed.

### Logging-only hook

Purpose:

- verify that generated Logos hook code executes on-device
- provide observable behavior without system modifications

Possible signal:

- write a marker file under `/var/mobile/Library/Logs/`
- avoid continuous logging or noisy hooks

### UIKit link test

Purpose:

- validate UIKit framework stub and headers if needed by future examples

Risk:

- larger framework surface
- more symbols may be needed

### PreferenceLoader test

Purpose:

- validate preference bundle packaging only if UI/config support becomes a toolchain target

Risk:

- more package paths
- more device state exposure

### Multi-architecture package test

Purpose:

- evaluate armv7/armv7s/arm64 packaging later

Risk:

- current recovered toolchain lane is armv7-first

### Deployment target matrix test

Purpose:

- verify iOS deployment target flags and link output across old targets

Risk:

- compatibility claims can get messy quickly

## Current next edge case

Next edge case:

    LogosHookTest device runtime validation

Do not add new examples until that boundary is crossed.
