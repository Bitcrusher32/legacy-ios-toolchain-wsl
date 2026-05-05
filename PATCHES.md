# Linux/WSL Compatibility Patching

This project originally experimented with hand-written `.patch` files. Those early patch sketches were later replaced because they were brittle and not valid reliable unified patches for a fresh reproduction run.

The current live patching path is:

    scripts/apply-linux-wsl-patches.py

`build-toolchain.sh` invokes that Python patcher after cloning the base toolchain and initializing submodules.

## Base repo

https://github.com/Tidal-Loop/linux-ios-toolchain

## Validated host

- WSL Ubuntu 24.04.3 LTS

## Validated target context

- iPhone 4s
- iOS 6.1.3
- ARMv7

## Major compatibility fixes applied by the patcher

- Remove Darwin/BSD-only `sys/sysctl.h` includes across ld64 sources.
- Replace BSD `sysctl()` CPU-count detection in `InputFiles.cpp` with `sysconf(_SC_NPROCESSORS_ONLN)`.
- Replace Darwin host SDK-version inference in `Options.cpp` with deterministic fallback behavior.
- Patch `libstuff/macosx_deployment_target.c` to avoid Darwin `sysctl(KERN_OSRELEASE)` host logic.
- Fix `memutils.h` for modern Linux/Clang C++ behavior:
  - add standard headers
  - remove unavailable Apple-only `security_utilities` dependency
  - handle `ptrdiff_t`
- Fix modern Clang/C++ parsing of old ld64 `CFI_Atom_Info` template type references.
- Apply changes idempotently so reruns do not corrupt already-patched sources.

## Current validation level

Confirmed:

- Fresh toolchain clone is patched automatically.
- Submodules are initialized automatically.
- `./configure arm-apple-darwin` is run by the build script.
- cctools and ios-tools build on WSL Ubuntu 24.04.
- `sudo make install` installs tools into `/usr/bin`.
- ARMv7 Mach-O smoke verification passes.

Also validated after Theos setup:

- no-op `.deb` package
- Objective-C runtime symbol `.deb` package
- CoreFoundation symbol `.deb` package
- Foundation symbol `.deb` package

Not yet confirmed:

- Logos hook package after latest wrappers/stubs
- MobileSubstrate/CydiaSubstrate link stubs
- device install/uninstall
- FakeGPS logic
