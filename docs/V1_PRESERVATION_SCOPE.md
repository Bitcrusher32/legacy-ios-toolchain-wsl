# V1 Preservation Scope

V1 covers the legacy iOS ARMv7 toolchain + Theos host-side preservation/reproducibility scope.

## V1 completed outcomes

- recover and patch the legacy toolchain for WSL Ubuntu 24.04
- automate Linux/WSL source patching
- build/install/verify the toolchain
- set up Theos wrappers
- generate Mach-O SDK stubs
- validate no-op, ObjC runtime, CoreFoundation, Foundation, and Logos package builds
- move examples into the repo
- add a full host validation script
- export the working WSL distro as a private appliance tar
- import the WSL appliance and re-run validation successfully

## V1 non-goals

- device install
- device uninstall
- runtime SpringBoard hook validation
- FakeGPS logic
- CoreLocation/locationd hooks
- preference bundles/UI

## Next scope boundary

The next scope is device safety.

Before implementation work, write and follow a harmless install/uninstall protocol.
