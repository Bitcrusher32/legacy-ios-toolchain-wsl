# Target Matrix

This matrix tracks what legacy iOS targets are actually validated.

Do not mark a target supported without evidence.

## Status legend

- `validated-host`: host build/package pipeline passed
- `validated-device-install`: device install/uninstall passed
- `validated-device-runtime`: respring/runtime lifecycle passed
- `planned`: reasonable future lane, not proven
- `unknown`: not evaluated

## Current matrix

| Lane | Device class | iOS | Arch | Host build | Device install | Runtime/respring | Notes |
|---|---|---:|---|---|---|---|---|
| A | iPhone 4s | 6.1.3 | armv7 | validated-host | validated-device-install for NoOpTweak | validated-device-runtime for NoOpTweak | Primary proven lane |
| A2 | iPhone 4s | 6.1.3 | armv7 | validated-host | validated-device-install for LogosHookTest | validated-device-runtime for LogosHookTest | Logos runtime boundary crossed |
| A3 | iPhone 4s | 6.1.3 | armv7 | validated-host | validated-device-install for LogosLoggingTest | validated-device-runtime for LogosLoggingTest | Hook-body observability marker validated |
| B | iPhone 4 / iOS 5.x or 6.x class | 5.x/6.x | armv7 | unknown | unknown | unknown | Future lane |
| C | iPhone 5 class | 6.x/7.x | armv7s | unknown | unknown | unknown | Future lane |
| D | early arm64 devices | 7.x/8.x | arm64 | unknown | unknown | unknown | Future lane; likely separate constraints |
| E | legacy simulator | varies | i386 | unknown | n/a | n/a | Optional future lane |

## Current proven lane details

Lane A has validated:

- legacy toolchain build/install/verify
- Theos wrapper setup
- Mach-O stub generation
- repo-hosted examples
- full host validation pipeline
- WSL appliance export/import
- NoOpTweak package inspection
- NoOpTweak device install/file placement/uninstall
- NoOpTweak controlled respring/runtime tolerance
- NoOpTweak post-uninstall respring and final clean state

Lane A has now validated LogosHookTest runtime behavior.

Lane A has not yet validated:

- behavior-changing hooks
- preference bundles
- application-specific tweak behavior

## Adding a new lane

A new lane needs:

1. target device/iOS/architecture definition
2. SDK/deployment target decision
3. host package build
4. package inspection
5. transfer/control workflow
6. install/uninstall test
7. runtime/respring test
8. rollback notes
9. LogDoc checkpoint

## V2.27 planning notes

The V2.27 appliance export validates the current host environment as a restorable WSL lane, not as a broad device-compatibility claim.

Private appliance:

- `legacy-ios-toolchain-wsl-V2.27.tar`
- size: about 5438 MB
- SHA256: `03C9B64C26F59F771DD0DDBCEBCDFEEFB008B8784012240DB977AA8B811B228C`

Restore validation passed:

- toolchain smoke verification
- Theos wrapper setup
- Mach-O stub generation
- full host validation pipeline through `logos-logging-test`
- generated artifact cleanup

Do not publish the appliance tar. It may contain private environment residue.

## Planned target-lane expansion

These lanes are planning targets only. They are not supported until validated.

| Lane | Device class | iOS | Arch | Status | Why it matters | First validation target |
|---|---|---:|---|---|---|---|
| A | iPhone 4s | 6.1.3 | armv7 | validated | Current primary proven lane | Already validated through LogosLoggingTest |
| B | iPhone 4 | 5.x-6.x | armv7 | planned | Common older 32-bit legacy target | host build + no-op install/runtime |
| C | iPad 2 / iPad mini 1 | 6.x | armv7 | planned | Common A5-era tablet target | host build + no-op install/runtime |
| D | iPhone 5 | 6.x-7.x | armv7s | planned | Tests armv7s packaging/runtime assumptions | host build + no-op install/runtime |
| E | iPhone 5s / early arm64 | 7.x-8.x | arm64 | research-only | Likely needs separate toolchain/linker constraints | host-only investigation first |
| F | legacy simulator | varies | i386 | optional | May help host-side compile checks | host-only build lane |

## Requirements before marking a new lane validated

A new device lane needs:

1. target device and exact iOS version recorded
2. SSH/control path confirmed
3. package transfer path confirmed
4. host build passes
5. package inspection passes
6. no-op install/file-placement/uninstall passes
7. controlled respring/runtime tolerance passes
8. post-uninstall clean state passes
9. LogDoc checkpoint created
10. repo docs updated

For hook-capable lane validation, also require:

1. minimal LogosHookTest runtime lifecycle
2. logging-only hook marker validation
3. marker cleanup and final clean state
