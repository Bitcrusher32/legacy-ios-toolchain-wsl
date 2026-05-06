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
