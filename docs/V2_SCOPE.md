# V2 Scope

V2 re-scopes this repository as a legacy iOS ARMv7 toolchain, validation, and preservation toolkit.

The active project is no longer a GPS spoofing tweak.

## Active project identity

This repository is now focused on:

- rebuilding a legacy iOS ARMv7 toolchain on WSL/Linux
- preserving a known-good WSL appliance
- wiring Theos to the recovered toolchain
- generating Mach-O stubs for old `ld64`
- validating harmless Theos package builds
- validating controlled device-side install/runtime/uninstall lifecycles
- documenting failure signatures and fixes
- expanding toward other common lost legacy iOS build targets

## Current primary lane

The current proven lane is:

- iPhone 4s
- iOS 6.1.3
- build 10B329
- ARMv7
- Cydia / MobileSubstrate environment
- Theos package workflow
- Windows 11 + WSL Ubuntu 24.04 host

## V2 immediate goals

1. Keep the host toolchain reproducible.
2. Keep the WSL appliance private and restorable.
3. Keep the repo-hosted host validation pipeline green.
4. Validate device runtime behavior using harmless packages only.
5. Validate logging-only hook observability next.
6. Build a target matrix before claiming broader compatibility.
7. Add new examples only when they prove reusable toolchain/runtime edge cases.

## Out of active scope

The following are not active goals for this repository:

- GPS spoofing as a product
- CoreLocation or locationd spoofing
- system-wide location spoofing
- preference UI for a spoofing tweak
- application-specific tweak behavior

Those may become downstream consumer projects later. They should not drive the core toolchain repository.

## Support policy

Do not claim a target is supported until it has a documented validation lane.

Minimum support evidence should include:

- host build/toolchain verification
- Theos wrapper setup
- Mach-O stub generation if needed
- package build
- package inspection
- device runtime validation where possible

## Current boundary

The next boundary is not application logic.

The Logos/MobileSubstrate runtime boundary has been crossed for LogosHookTest on the iPhone 4s / iOS 6.1.3 / ARMv7 lane. The next boundary is logging-only hook observability.
