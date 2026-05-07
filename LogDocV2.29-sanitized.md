# Legacy iOS ARMv7 / iPhone 4s iOS 6.1.3 Toolchain LogDoc

[META NOTE: REDACTIONS REPRESENTED AS ▓ CHARACTERS]


Last updated: 2026-05-04
Owner/system: bitcrusher32 on Windows 11 + WSL Ubuntu 24.04.3 LTS
Purpose: Living project-management / sysadmin-style context file for rebuilding, preserving, testing, and extending a legacy iOS ARMv7 build toolchain. V2 scope removes FakeGPS as the active project goal and focuses on toolchain validation, edge-case testing, and future lost-target support.

---

## 1. Project Goal

V2 scope: build, preserve, validate, and generalize a legacy iOS ARMv7 build environment for WSL/Linux.

The active project is no longer a FakeGPS tweak.

The current primary validation target remains:

- iPhone 4s
- iOS 6.1.3
- Build 10B329
- ARMv7
- Cydia / MobileSubstrate environment
- Theos package workflow

Mission order, by criticality:

1. Preserve a reproducible legacy iOS ARMv7 toolchain on WSL/Linux.
2. Keep the toolchain build/install/verify path reproducible from Git.
3. Preserve a container-adjacent known-good WSL appliance.
4. Maintain clean Theos integration and wrapper setup.
5. Maintain Mach-O stub generation for old ld64 compatibility.
6. Validate host-side builds across representative package types:
   - no-op tweak
   - Objective-C runtime test
   - CoreFoundation test
   - Foundation test
   - Logos/MobileSubstrate hook test
7. Validate device-side safety using harmless packages only:
   - package inspection
   - transfer
   - dpkg install
   - file placement
   - respring/runtime tolerance
   - uninstall
   - post-uninstall clean state
8. Expand edge-case testing for iOS 6.1.3 / ARMv7.
9. Generalize the workflow toward other common lost legacy iOS build targets.
10. Document failure signatures, fixes, validation ladders, and risk boundaries.

Explicitly out of active scope:

- FakeGPS as the primary project goal
- GPS spoofing MVP
- CoreLocation/locationd spoofing
- system-wide location spoofing
- preference UI for GPS spoofing
- any device-risky tweak behavior before toolchain/runtime safety is validated

Immediate milestones under V2:

- Finish repo docs so they no longer present FakeGPS as the active goal.
- Commit/push V2 scope docs.
- Continue with LogosHookTest package inspection and controlled runtime validation.
- Build a target matrix for iOS 6.1.3 first, then future legacy iOS targets.
- Keep the WSL appliance private and the Git repo as the reproducible public recipe.

Historical note:

Pre-V2 references to FakeGPS are preserved as project history and debugging context, but they no longer define the active project scope.

---

## 2. Target Device State

Device:
- iPhone 4s
- iOS 6.1.3
- Build: 10B329
- Jailbroken
- Cydia-style environment
- Genuine imported unit from China
- Contains China-only / unusual legacy apps that should be preserved.

Preservation notes:
- Apps were backed up via 3uTools, but backup reliability has not been fully tested.
- Avoid restore/update paths unless absolutely necessary.
- Treat device state as precious.

Connectivity:
- OpenSSH installed from Cydia.
- SSH works via PuTTY from Windows.
- SSH credential detail: ▓▓.
- SSH currently requires Windows Wi-Fi hotspot because iPhone 4s cannot connect to the main router setup.
- Main router issue: Wi-Fi 6 / 5 GHz / WPA3 incompatibility with iPhone 4s-era wireless support.

Confirmed installed packages / substrate state:
- Cydia opens normally.
- apt / dpkg present.
- mobilesubstrate installed.
- com.saurik.substrate.safemode installed.
- preferenceloader installed.
- MobileSubstrate DynamicLibraries folder exists.

Observed DynamicLibraries entries include:
- AppSync.dylib / AppSync.plist
- AppSyncUnified*.dylib / plist variants
- FakeLocation.dylib / FakeLocation.plist
- MobileSafety.dylib / MobileSafety.plist
- PreferenceLoader.dylib / PreferenceLoader.plist
- StocksX.dylib / StocksX.plist
- VeterisHelper.dylib

Architecture:
- Target believed to be ARMv7 / 32-bit ARM.
- Exact final compile flags still need verification.

---

## 3. Host System State

Host:
- Windows 11
- WSL Ubuntu

WSL OS:
PRETTY_NAME="Ubuntu 24.04.3 LTS"
NAME="Ubuntu"
VERSION_ID="24.04"
VERSION="Ubuntu 24.04.3 LTS (Noble Numbat)"
VERSION_CODENAME=noble
ID=ubuntu
ID_LIKE=debian
UBUNTU_CODENAME=noble

Home directory topology observed:

~/ contains:
- FakeGPS
- linux-ios-toolchain
- theos
- theos_old

Current FakeGPS topology observed:

~/FakeGPS contains:
- FakeGPS
- Makefile
- Tweak.xm

~/FakeGPS/FakeGPS contains:
- FakeGPS.plist
- Makefile
- Tweak.x
- control

Important topology note:
- Nested ~/FakeGPS/FakeGPS is likely accidental/messy.
- Current project source is disposable.
- Recreate clean project later after toolchain works.

---

## 4. Toolchain / Framework Context

Modern/standard Theos path did not work for this target.

Chosen repo:
https://github.com/Tidal-Loop/linux-ios-toolchain

Why:
- Other approaches were too new, unsupported, or broken for iOS 6.1.3 / WSL / legacy ARMv7.
- This repo is old Google Code / macOS-oriented iOS toolchain lineage.

Known issue class:
- Darwin/macOS-oriented cctools/ld64 code is being compiled on modern Ubuntu/Clang.
- Current breakage is in the toolchain build, not tweak source.

Recovered terminal log:
- bitcrusher32@▓▓ ~linux-ios-toolchain.txt
- Long recovered terminal I/O from lost private chat.

---

## 5. Build State So Far

Toolchain build appears to have completed through cctools and ios-tools.
No .deb produced yet.
No tweak test compile has happened yet.

Known previous command:
```bash
cd ~/linux-ios-toolchain
CFLAGS="-fcommon" CXXFLAGS="-fcommon" make 2>&1 | tee build.log
```

Known earlier non-critical issue:
- `make clean -C build/iphonesdk-utils-2.0`
- failed with `No rule to make target 'clean'`
- This was during clean target, not the main compile milestone.

Known current fatal toolchain error:
- Build reaches cctools/ld64/src/ld/parsers.
- Fails compiling `macho_relocatable_file.cpp`.
- `grep -n "error:" build.log | tail -30` showed:
  - `macho_relocatable_file.cpp:4120:61: error: qualified reference to 'CFI_Atom_Info' is a constructor name rather than a type in this context`
  - `macho_relocatable_file.cpp:4182:58: error: qualified reference to 'CFI_Atom_Info' is a constructor name rather than a type in this context`
  - `macho_relocatable_file.cpp:4203:58: error: qualified reference to 'CFI_Atom_Info' is a constructor name rather than a type in this context`
  - `macho_relocatable_file.cpp:4215:60: error: qualified reference to 'CFI_Atom_Info' is a constructor name rather than a type in this context`
- Make then fails:
  - `make[5]: *** [Makefile:433: libParsers_la-macho_relocatable_file.lo] Error 1`
  - `make: *** [Makefile:13: cctools.stamp] Error 2`

Other compile issue visible nearby:
- Variable length array / constant expression warning or error area around `char symName[nameLen+2]`.
- Need confirm whether this remains fatal after the CFI_Atom_Info fix.

Bad prior action to avoid:
- A C++ function signature was accidentally pasted into the shell after opening nano:
  - shell reported syntax errors near `(`.
- Future patches should be applied using sed/perl/python or carefully inside editor only.

---

## 6. Current Risk Model

High-risk things to avoid unless deliberately chosen:
- Restoring/updating the iPhone.
- Wiping the imported device.
- Trusting the 3uTools backup without validation.
- Installing random packages before SSH recovery/uninstall path is known.
- Testing GPS tweak before a harmless no-op package.

Safer assumptions:
- Treat phone as precious.
- Treat WSL/toolchain/project as disposable.
- Build host-side first.
- Confirm uninstall/recovery before installing anything meaningful.

---

## 7. Current Debugging Plan

Current V2 plan: toolchain/runtime validation, not GPS spoof implementation.

Phase A: Toolchain preservation.
1. Keep the patched linux-ios-toolchain reproducible.
2. Keep install/verify scripts working on WSL Ubuntu.
3. Preserve WSL appliance export/import workflow.
4. Keep generated artifacts out of active Git paths.

Phase B: Theos integration.
1. Maintain setup-theos-toolchain-links.sh.
2. Maintain compiler/linker/ldid wrappers.
3. Maintain Mach-O stub generation.
4. Keep validate-host-pipeline.sh green.

Phase C: Host package edge-case testing.
1. Continue validating no-op, ObjC runtime, CoreFoundation, Foundation, and Logos examples.
2. Add additional edge-case examples only when they test a specific missing symbol/framework/runtime pattern.
3. Keep examples harmless and minimal.
4. Avoid turning examples into application-specific tweaks.

Phase D: Device runtime safety.
1. Use the known-good WSL -> Windows -> pscp -> PuTTY workflow.
2. Inspect packages before install.
3. Install only harmless packages.
4. Confirm file placement.
5. Use controlled respring tests.
6. Uninstall and post-uninstall respring.
7. Record every result.

Phase E: Broader target expansion.
1. Build an iOS/architecture target matrix.
2. Start from known stable iPhone 4s / iOS 6.1.3 / ARMv7.
3. Add other legacy targets only as separate validation lanes.
4. Never claim compatibility until host build and, where possible, device validation are proven.

---

## 8. Immediate Commands To Run Next

Run from WSL:

```bash
cd ~/linux-ios-toolchain

# snapshot the current failing file before patching
cp build/cctools/cctools/ld64/src/ld/parsers/macho_relocatable_file.cpp \
   build/cctools/cctools/ld64/src/ld/parsers/macho_relocatable_file.cpp.pre-cfi-fix

# inspect exact failing lines
nl -ba build/cctools/cctools/ld64/src/ld/parsers/macho_relocatable_file.cpp | sed -n '4100,4230p'
```

Send that output before patching if you want assistant confirmation.

Likely patch direction:
- Replace bad nested type spelling like:
  `libunwind::CFI_Atom_Info<...>::CFI_Atom_Info`
- With:
  `libunwind::CFI_Atom_Info<...>`

But confirm exact lines first.

---

## 9. Notes For Assistant

The question segment is closed for now.
Proceed with direct debugging.
Do not skip context.
Do not risk device state casually.
Focus on toolchain milestone before tweak implementation.


---

## 10. Patch Timeline (v1)

1. Fixed ld64 CFI parser template errors:
   - Replaced invalid nested constructor-style type references:
     `CFI_Atom_Info<...>::CFI_Atom_Info` -> `CFI_Atom_Info<...>`

2. Fixed macOS-only sysctl usage in InputFiles.cpp:
   - Removed duplicate `#include <sys/sysctl.h>`
   - Replaced sysctl CPU detection with:
     `sysconf(_SC_NPROCESSORS_ONLN)`

3. Fixed header dependency in InputFiles.h:
   - Removed `#include <sys/sysctl.h>`

4. Current state:
   - Build now fails in ld.cpp with same missing header:
     `fatal error: 'sys/sysctl.h' file not found`

Next step:
   - Apply same removal strategy to ld.cpp
   - Check if sysctl is used or only included


5. Fixed ld.cpp direct sysctl include:
   - Removed `#include <sys/sysctl.h>` from:
     `build/cctools/cctools/ld64/src/ld/ld.cpp`
   - Rebuild advanced past ld.cpp’s own include.
   - New failure moved to:
     `Resolver.h:32:10: fatal error: 'sys/sysctl.h' file not found`

6. Prepared wider ld64 sysctl purge:
   - Reason: repeated dead Darwin/BSD `sys/sysctl.h` includes are appearing across ld64 headers/source.
   - Sanity backup command planned before destructive purge:
     ```bash
     cp -r build/cctools/cctools/ld64 build/cctools/cctools/ld64.pre-sysctl-purge
     ```
   - Planned purge command:
     ```bash
     grep -rl '#include <sys/sysctl.h>' build/cctools/cctools/ld64 | while read f; do
         sed -i 's|#include <sys/sysctl.h>||g' "$f"
     done
     ```
   - Verification command:
     ```bash
     grep -r "sys/sysctl.h" build/cctools/cctools/ld64
     ```
   - Expected verification result:
     no output.
   - Rationale:
     The only confirmed real sysctl usage so far was the CPU-count block in `InputFiles.cpp`, already replaced with `sysconf(_SC_NPROCESSORS_ONLN)`. Remaining failures are header-level Darwin include residue unless future grep shows actual sysctl calls.


7. Executed full ld64 sysctl purge:
   - Created backup:
     cp -r build/cctools/cctools/ld64 build/cctools/cctools/ld64.pre-sysctl-purge
   - Removed all occurrences of:
     #include <sys/sysctl.h>
     across ld64 source tree.
   - Verified no remaining includes via grep (0 results).
   - Result:
     Build progressed significantly deeper into ld64.

8. Fixed Options.cpp Darwin sysctl OS version logic:
   - Removed sysctl-based kernel version detection block using:
     CTL_KERN / KERN_OSRELEASE
   - Replaced with constant fallback:
     fSDKVersion = 0x000A0800 (macOS 10.8 equivalent)
   - Rationale:
     This logic is host-side only and not relevant for Linux cross-build.
   - Result:
     Build progressed past Options.cpp.

9. Current failure (post-purge, post-Options fix):
   - File: code-sign-blobs/memutils.h
   - Error:
     unknown type name 'ptrdiff_t'
   - Root cause:
     Missing standard definition from <stddef.h> / <cstddef>.
   - Planned fix:
     Add:
       #include <stddef.h>
     near top of memutils.h

Current state:
   - ld64 build is now in late-stage compilation.
   - Remaining issues are standard library compatibility fixes (low complexity).


10. Fixed code-sign-blobs/memutils.h Apple-only include:
   - Enabled:
     #include <stddef.h>
   - Removed:
     #include <security_utilities/utilities.h>
   - Rationale:
     memutils.h already defines the helpers used locally:
     alignUp, increment, difference.
     The Apple security_utilities header is not present on Linux/WSL.
   - Result:
     Build progressed past code-sign-blobs/blob.cpp.

11. Apparent toolchain build completion:
   - cctools completed and stamped:
     touch cctools.stamp
   - iphonesdk-utils-2.0 completed and stamped:
     touch ios-tools.stamp
   - No fatal compiler error was visible in the submitted full build log.
   - Current status:
     Treat build as likely successful, pending verification of generated binaries and `make install`.

12. New milestone inserted before FakeGPS dev setup:
   - Publish/reconstruct this patched legacy iOS toolchain environment in Git before building the actual FakeGPS tweak.
   - Goal:
     Someone should eventually be able to clone/download the repo, install prerequisites on WSL Ubuntu 24.04.3, apply patches or use patched source, build, install, and begin legacy iOS tweak development.
   - Unknown:
     Compatibility scope is not yet proven.
     Current validated target is iPhone 4s / iOS 6.1.3 / ARMv7.
     It may work for other legacy iOS/ARMv7 targets, but that should be documented as unverified until tested.
   - Suggested future repo shape:
     - README.md
     - PATCHES.md
     - scripts/install-deps-ubuntu-24.04.sh
     - scripts/build-toolchain.sh
     - scripts/verify-toolchain.sh
     - patches/
     - logs/
     - examples/noop-tweak/
   - Avoid claiming broad iOS compatibility until test compile/package/install validation is complete.

Current next step:
   - Verify generated binaries.
   - Run `make install`.
   - Then verify installed commands exist before starting no-op tweak test.


13. Installed toolchain to system (/usr/bin):
   - Ran:
     sudo make install
   - Resolved permission issues by using sudo.
   - Installed binaries include:
     /usr/bin/arm-apple-darwin-ar
     /usr/bin/arm-apple-darwin-ld
     /usr/bin/arm-apple-darwin-as
     /usr/bin/ldid
   - Verified using `which`:
     toolchain is now globally accessible in WSL environment.

14. Milestone achieved: Working + installed legacy iOS toolchain
   - Toolchain successfully:
     - Builds
     - Installs
     - Exposes expected binaries in PATH
   - This is the first **functional milestone**, not just a compile milestone.
   - Environment is now usable for:
     - Test compilation
     - Future tweak development
     - Reproducible setup scripting

Current state:
   - Toolchain: BUILT + INSTALLED + VERIFIED
   - Next milestone:
     Create minimal test compile (no-op tweak or simple C file)
   - Parallel milestone:
     Begin structuring Git repo for reproducible environment


15. Minimal ARMv7 Mach-O smoke tests completed:
   - Created test assembly:
     ~/ios-toolchain-tests/asm/test.s
   - Assembler test:
     arm-apple-darwin-as -arch armv7 -o test.o test.s
     Result:
     test.o: Mach-O armv7 object
   - Relocatable linker test:
     arm-apple-darwin-ld -arch armv7 -r -o test_reloc.o test.o
     Result:
     test_reloc.o: Mach-O armv7 object
   - Archive test:
     arm-apple-darwin-ar rcs libtest.a test.o
     arm-apple-darwin-ar t libtest.a
     Result:
     libtest.a: current ar archive random library
     archive members:
       __.SYMDEF SORTED
       test.o

16. Clarified failed full-executable linker test:
   - Command attempted:
     arm-apple-darwin-ld -arch armv7 -o test_macho test.o
   - Result:
     ld warned that -ios_version_min was not specified and assumed 6.0.
     ld refused to create a dynamic main executable without libSystem.dylib.
   - Interpretation:
     This is expected linker behavior, not a toolchain failure.
     Full executable linking requires SDK/libSystem paths and proper iOS link flags.
   - Decision:
     Use relocatable object test as current linker smoke test until SDK path is pinned.

17. Git reproduction stage started:
   - Created initial snapshot folders:
     ~/legacy-ios-toolchain-wsl/scripts
     ~/legacy-ios-toolchain-wsl/patches
     ~/legacy-ios-toolchain-wsl/logs
     ~/legacy-ios-toolchain-wsl/examples/noop-asm
   - Copied smoke-test assembly into:
     ~/legacy-ios-toolchain-wsl/examples/noop-asm/test.s
   - Began README.md / VERIFY.md creation.
   - User manually verified key paths:
     /usr/bin/arm-apple-darwin-ar
     /usr/bin/arm-apple-darwin-ld
     /usr/bin/arm-apple-darwin-as
     /usr/bin/ldid

18. Current breakpoint:
   - Toolchain build/install/smoke-test milestone is complete.
   - Git reproduction milestone is in progress but not complete.
   - VERIFY.md was started but may be incomplete due to interrupted heredoc/code-block formatting.
   - Next session should repair/finish Git repo docs and scripts before moving into FakeGPS/no-op tweak setup.

Current state:
   - Toolchain: BUILT + INSTALLED + PATH VERIFIED
   - Smoke tests: assembler + relocatable linker + archive PASSED
   - Full executable linking: intentionally deferred until SDK/libSystem discovery
   - Git reproduction: folder scaffold started, docs/scripts unfinished


19. Git reproduction docs/scripts completed enough for baseline commit:
   - Completed/cleaned:
     README.md
     PATCHES.md
     VERIFY.md
     .gitignore
     scripts/verify-toolchain.sh
     examples/noop-asm/test.s
   - `scripts/verify-toolchain.sh` was made executable.
   - The verify script successfully checks:
     /usr/bin/arm-apple-darwin-ar
     /usr/bin/arm-apple-darwin-ld
     /usr/bin/arm-apple-darwin-as
     /usr/bin/ldid
   - The verify script successfully runs ARMv7 Mach-O smoke tests:
     - assemble test.s into test.o
     - link relocatable object test_reloc.o
     - archive test.o into libtest.a

20. Git repository initialized and baseline committed:
   - Repository path:
     ~/legacy-ios-toolchain-wsl
   - Git initialized successfully.
   - Commit created:
     ca2fa10 Baseline: working legacy iOS ARMv7 toolchain on WSL
   - Commit stats:
     6 files changed
     223 insertions
   - Files committed:
     .gitignore
     PATCHES.md
     README.md
     VERIFY.md
     examples/noop-asm/test.s
     scripts/verify-toolchain.sh

21. Milestone achieved: Git baseline for reproducible toolchain environment
   - This is now more than a local one-off fix.
   - Current repo preserves:
     - validated status
     - patch timeline
     - verification procedure
     - smoke test example
     - executable verification script
   - Still not complete as a fully reproducible public release because actual patch files and build automation are not yet formalized.

Current state:
   - Toolchain: BUILT + INSTALLED + PATH VERIFIED
   - Smoke tests: PASSED
   - Git baseline: COMMITTED
   - Next milestone:
     Convert patch history into real patch files and/or build scripts.
   - After that:
     Start no-op tweak / Theos build validation before FakeGPS implementation.


22. Gitea repository created and initial push completed:
   - Remote:
     https://git.bitcrusher32.win/bitcrusher32/theros-monumental-wsl-toolkit
   - Branch:
     main (or master depending on initial config)
   - Contents visible:
     README.md
     PATCHES.md
     VERIFY.md
     .gitignore
     scripts/verify-toolchain.sh
     examples/noop-asm/test.s
   - Repository description currently minimal.

23. Milestone achieved: External hosted baseline
   - Toolchain work is now:
     - locally reproducible (manual)
     - documented
     - version controlled
     - remotely backed up (Gitea)
   - This marks transition from:
     "local recovery/debug effort"
     to:
     "structured project with external persistence"

24. Current interpretation of project phase:
   - Phase A (Toolchain recovery): COMPLETE
   - Phase B (Environment validation): COMPLETE (smoke-test level)
   - Phase C (Reproducibility scaffolding): PARTIALLY COMPLETE
   - Phase D (Tweak development): NOT STARTED

Current state:
   - Toolchain: BUILT + INSTALLED + VERIFIED
   - Smoke tests: PASSED
   - Git (local): COMMITTED
   - Git (remote): PUSHED TO GITEA
   - Next milestone:
     Formalize reproducibility (patch files + build scripts)
   - After that:
     First no-op tweak compile using Theos + this toolchain

Breakpoint note:
   - Safe to pause here.
   - System is in a stable, checkpointed state across:
     WSL filesystem
     local git repo
     remote Gitea repo



25. Began formal patch extraction phase (reproducibility work):
   - Identified that large auto-generated diff (~10k lines) was unsuitable for repo use.
   - Decision made to replace it with small, scoped, human-readable patches.

26. Created patch: 0001-remove-sysctl-includes.patch
   - Scope:
     Remove Darwin-only `#include <sys/sysctl.h>` from ld64 source.
   - Purpose:
     Eliminate missing header errors on Linux.
   - Status:
     Clean, minimal patch created and verified.

27. Created patch: 0002-inputfiles-use-sysconf.patch
   - Scope:
     Replace sysctl-based CPU detection in InputFiles.cpp.
   - Change:
     sysctl(CTL_HW/HW_NCPU) -> sysconf(_SC_NPROCESSORS_ONLN)
   - Purpose:
     Replace BSD-specific runtime logic with POSIX-compatible equivalent.
   - Status:
     Verified.

28. Created patch: 0003-options-sdk-fallback.patch
   - Scope:
     Replace Darwin kernel version detection in Options.cpp.
   - Change:
     Removed sysctl-based logic and replaced with:
       fSDKVersion = 0x000A0800
   - Purpose:
     Remove host-dependent logic and enforce deterministic fallback on Linux.
   - Status:
     Verified.

29. Current reproducibility state:
   - Patch set is being reconstructed incrementally.
   - Remaining patches to formalize:
     - memutils.h Linux compatibility fix
     - CFI_Atom_Info template fix
   - build-toolchain.sh currently requires manual patch application.

30. Milestone progression update:
   - Phase A (Toolchain recovery): COMPLETE
   - Phase B (Validation): COMPLETE
   - Phase C (Reproducibility scaffolding): IN PROGRESS (patch extraction phase)
   - Phase D (Tweak dev): NOT STARTED

Current state:
   - Toolchain: BUILT + INSTALLED + VERIFIED
   - Smoke tests: PASSED
   - Git: LOCAL + REMOTE SYNCED
   - Reproducibility: PARTIAL (scripts exist, patches incomplete)

Next milestone:
   - Complete remaining patch files
   - Integrate patch application into build script
   - Achieve "clone → build → verify" fully automated pipeline

Breakpoint note:
   - Safe partial reproducibility achieved
   - System state stable and version-controlled


31. Completed remaining core patch files:
   - Created patch:
     patches/0004-memutils-linux-headers.patch
   - Scope:
     code-sign-blobs/memutils.h
   - Change:
     Enabled:
       #include <stddef.h>
     Removed:
       #include <security_utilities/utilities.h>
   - Purpose:
     Provide ptrdiff_t definition and remove unavailable Apple-only security_utilities dependency.
   - Status:
     Verified by inspection.

32. Created patch:
   - patches/0005-cfi-atom-info-template-fix.patch
   - Scope:
     ld64/src/ld/parsers/macho_relocatable_file.cpp
   - Change:
     Replaced invalid nested constructor-style template type references:
       libunwind::CFI_Atom_Info<...>::CFI_Atom_Info
     with:
       libunwind::CFI_Atom_Info<...>
   - Purpose:
     Fix modern Clang/C++ parsing errors where the old source treated a constructor name as a type.
   - Status:
     Verified by inspection.

33. Integrated automated patch application into build-toolchain.sh:
   - build-toolchain.sh now computes stable paths:
     SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
     REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
   - build-toolchain.sh now applies:
     "${REPO_ROOT}"/patches/*.patch
   - Patch command:
     patch -p1 < "$patch_file"
   - Rationale:
     Avoid relying on relative paths after changing directory into the cloned linux-ios-toolchain workdir.

34. Pushed first automated patched toolchain scaffold:
   - Local repo:
     ~/legacy-ios-toolchain-wsl
   - Remote:
     https://git.bitcrusher32.win/bitcrusher32/theros-monumental-wsl-toolkit
   - Current pushed state includes:
     - install dependency script
     - build script with automated patch loop
     - verification script
     - five compatibility patch files
     - docs and smoke-test example
   - Important caveat:
     This is the first untested automated patch/build push.
     Manual recovery build was validated, but full fresh-clone reproducibility test has not yet been run.

35. Current reproducibility milestone:
   - Patch set: COMPLETE enough for first full automated test
   - Build script integration: COMPLETE enough for first full automated test
   - Remote push: COMPLETE
   - Reproducibility testing: NOT STARTED

Current state:
   - Toolchain manual build/install: VERIFIED
   - Smoke tests: VERIFIED
   - Git remote baseline: PUSHED
   - Automated patch pipeline: PUSHED, UNTESTED
   - Next milestone:
     Run clean/fresh reproducibility test loop.
   - Expected next workflow:
     1. Clone repo into a clean test directory or use current repo as controller.
     2. Use scripts/install-deps-ubuntu-24.04.sh if needed.
     3. Run scripts/build-toolchain.sh against a fresh linux-ios-toolchain clone/location.
     4. Run scripts/verify-toolchain.sh.
     5. Fix patch fuzz/path/build issues as they appear.

Breakpoint note:
   - This is a strong checkpoint before testing loops.
   - If automated patches fail, the known-good manual WSL install still exists.


36. Began clean reproducibility test loop:
   - Created/used throwaway test area:
     ~/repro-test
   - Cloned remote project:
     https://git.bitcrusher32.win/bitcrusher32/theros-monumental-wsl-toolkit
   - Redirected build-toolchain.sh locally in the repro clone to use:
     ~/repro-test/linux-ios-toolchain-fresh
   - Purpose:
     Avoid touching known-good manual build at:
     ~/linux-ios-toolchain

37. First reproducibility failure: invalid patch files
   - Initial automated patch loop attempted:
     patch -p1 < patches/*.patch
   - Failure:
     patch: **** Only garbage was found in the patch input.
   - Cause:
     The `.patch` files were documentation-shaped diffs, not valid unified patches with line-number hunks.
   - Decision:
     Replace fragile hand-written patch files with a Python patcher that edits exact source patterns.

38. Second reproducibility failure: missing submodule initialization
   - Fresh linux-ios-toolchain clone had:
     build/cctools/
     but not:
     build/cctools/cctools/ld64/...
   - Investigation showed:
     build/cctools is a Git submodule:
       https://github.com/tpoechtrager/cctools-port.git
   - Fix:
     Add:
       git submodule update --init --recursive
     to build-toolchain.sh before patching.

39. Added idempotent Linux/WSL patcher:
   - New script:
     scripts/apply-linux-wsl-patches.py
   - Purpose:
     Apply source transformations directly and idempotently instead of relying on brittle patch files.
   - Patcher now accepts a toolchain root path argument:
     apply-linux-wsl-patches.py /path/to/linux-ios-toolchain
   - Reason:
     Avoid hardcoding ~/linux-ios-toolchain so repro tests can use throwaway paths.

40. Repro patcher bugs found and fixed:
   - Initial patcher had brittle whitespace assumptions.
   - InputFiles.cpp CPU-count replacement failed because regex character class was over-escaped:
     [ \\t] matched literal backslash/t instead of actual tabs.
   - Fix:
     Correct regex tab handling:
       [ \t] / actual tab-aware pattern
   - Result:
     InputFiles.cpp sysconf CPU-count patch became reproducible.

41. memutils.h patcher made tolerant:
   - Fresh source had:
       //#include <security_utilities/utilities.h>
       #include <sys/types.h>
     not the earlier expected:
       //#include <stddef.h>
       #include <security_utilities/utilities.h>
       #include <sys/types.h>
   - Fix:
     Patcher now:
       - removes active or commented security_utilities include
       - removes commented stddef include if present
       - inserts #include <stddef.h> before #include <sys/types.h> if missing
   - Result:
     memutils.h Linux header patch became reproducible.

42. build-toolchain.sh sequencing fixed:
   - Build reached top-level Makefile but failed:
     Makefile:1: configure.mk: No such file or directory
   - Cause:
     configure.mk is generated by:
       ./configure arm-apple-darwin
   - Fix:
     build-toolchain.sh now runs:
       ./configure arm-apple-darwin
     before make.
   - Result:
     Repro test entered the actual compile stage.

43. New compile incompatibility found outside ld64:
   - File:
     build/cctools/cctools/libstuff/macosx_deployment_target.c
   - Failure:
     fatal error: 'sys/sysctl.h' file not found
   - Inspection showed this file actually uses:
     CTL_KERN / KERN_OSRELEASE / sysctl()
     to infer host macOS deployment target.
   - This is another Darwin-host assumption, outside the earlier ld64-only patch scope.

44. Began patching libstuff deployment-target sysctl fallback:
   - Added macosx_deployment_target.c to apply-linux-wsl-patches.py.
   - Header removal works:
     #include <sys/sysctl.h> removed.
   - Fallback block replacement failed due to exact-pattern mismatch.
   - Inspection showed the actual block around use_default:
     - queries kern.osrelease via sysctl
     - parses kernel major/minor
     - falls back to 10.6 on bad value
     - then continues to warn_if_bad_user_values
   - Next action:
     Replace this fragile exact block with a regex/section patch from `use_default:` to `bad_system_value:` or to the `goto warn_if_bad_user_values;` region, preserving function flow.

45. Current reproducibility test status:
   - Submodule init: FIXED locally/committed
   - Python patcher path argument: FIXED locally/committed
   - InputFiles.cpp patch: FIXED locally/committed
   - Options.cpp patch: WORKING
   - memutils.h patch: FIXED locally/committed
   - CFI_Atom_Info patch: WORKING
   - configure.mk generation: FIXED locally/committed
   - libstuff macosx_deployment_target.c: IN PROGRESS, currently failing at fallback replacement pattern

Current state:
   - Known-good manual toolchain: still safe and installed
   - Repro build: reaches real cctools compile
   - Current repro blocker: macosx_deployment_target.c Darwin sysctl fallback
   - Git state:
     Several reproducibility fixes were committed locally during testing.
     Push should happen after the current patcher is known working.
   - Next milestone:
     Make libstuff deployment-target patch tolerant, rerun clean repro build, then push and create another LogDoc checkpoint.

Breakpoint note:
   - Major undocumented progress has now been captured.
   - The project is no longer stuck on patch application or source staging; it is in real compile compatibility loops.


46. Fixed macosx_deployment_target.c fallback patch:
   - Replaced brittle exact block with a regex/section-based replacement.
   - Scope:
     build/cctools/cctools/libstuff/macosx_deployment_target.c
   - Change:
     Removed Darwin sysctl-based kern.osrelease detection.
     Inserted deterministic Linux/WSL fallback:
       value->major = 8
       value->minor = 0
       value->name = "10.8"
       goto warn_if_bad_user_values
   - Result:
     Repro build advanced past libstuff/macOS deployment target compilation.

47. Expanded ld64 sysctl include removal:
   - Previous patcher removed sys/sysctl.h from a fixed list of ld64 files.
   - New compile failure found:
     ld64/src/ld/SymbolTable.h: fatal error: 'sys/sysctl.h' file not found
   - Fix:
     apply-linux-wsl-patches.py now scans all ld64 source/header files and removes:
       #include <sys/sysctl.h>
   - Additional issue:
     Broad scan initially crashed on a non-UTF8 file.
   - Fix:
     remove_exact() changed to operate on bytes instead of UTF-8 text.
   - Result:
     Broad ld64 sysctl removal became reproducible and byte-safe.

48. Fixed modern C++ ptrdiff_t issue in memutils.h:
   - Repro build reached:
     ld64/src/ld/code-sign-blobs/blob.cpp
   - Failure:
     memutils.h: unknown type name 'ptrdiff_t'; did you mean 'std::ptrdiff_t'?
   - Cause:
     Modern C++ headers exposed ptrdiff_t as std::ptrdiff_t in this context.
   - Fix:
     Patcher now inserts:
       #include <cstddef>
       using std::ptrdiff_t;
     while still ensuring:
       #include <stddef.h>
   - Result:
     Repro build advanced past code-sign-blobs/blob.cpp.

49. Fresh reproducibility build/install succeeded:
   - Test controller repo:
     ~/repro-test/theros-monumental-wsl-toolkit
   - Fresh toolchain workdir:
     ~/repro-test/linux-ios-toolchain-fresh
   - Build script flow completed:
     1. Clone/existing repo detection
     2. Submodule init
     3. Linux/WSL patcher
     4. ./configure arm-apple-darwin
     5. make
     6. sudo make install
   - End markers observed:
     touch ios-tools-install.stamp
     Build/install complete. Run verify-toolchain.sh from this repo next.
   - This confirms the automated repro path can build and install the toolchain from a fresh workdir.

50. Fresh reproducibility verification passed:
   - Ran:
     ./scripts/verify-toolchain.sh
   - Verified installed tools:
     /usr/bin/arm-apple-darwin-ar
     /usr/bin/arm-apple-darwin-ld
     /usr/bin/arm-apple-darwin-as
     /usr/bin/ldid
   - Smoke test results:
     test.o: Mach-O armv7 object
     test_reloc.o: Mach-O armv7 object
     libtest.a: current ar archive random library
     archive members:
       __.SYMDEF SORTED
       test.o
   - Verification output ended:
     Verification complete.

51. Build log sanity check:
   - Searched repro-build-12.log for:
     fatal error
     error:
     Error
     Traceback
     UnicodeDecodeError
     Permission denied
     No such file
   - Only hit:
     aclocal: warning: couldn't open directory 'm4': No such file or directory
   - Interpretation:
     Warning only; not a fatal build failure.

52. Milestone achieved: reproducible fresh build/install/verify
   - Manual known-good build was already validated earlier.
   - Now a fresh repro workdir has also:
     - initialized submodules
     - applied automated Linux/WSL patches
     - configured target
     - built
     - installed
     - passed ARMv7 Mach-O smoke verification
   - This upgrades the project from:
     "documented manual recovery"
     to:
     "working reproducible build automation."

Current state:
   - Toolchain manual build/install: VERIFIED
   - Fresh repro build/install: VERIFIED
   - Smoke tests: VERIFIED
   - Automated patcher: WORKING
   - Repro build script: WORKING
   - Git push: requested/expected after successful verification if not already done
   - Next milestone:
     Begin no-op Theos/tweak compile validation before touching FakeGPS logic.

Recommended immediate next steps:
   1. Push latest commits from ~/legacy-ios-toolchain-wsl to Gitea.
   2. Optionally update README/PATCHES to state reproducible build is now validated.
   3. Start no-op tweak compile in a clean project.
   4. Do not install meaningful GPS tweaks on the iPhone until a harmless .deb install/uninstall path is validated.

Breakpoint note:
   - This is a major stable checkpoint.
   - Reproducibility testing has succeeded.
   - The known-good manual environment and automated fresh environment both pass smoke tests.


53. Began no-op Theos/tweak compile validation:
   - Clean project created:
     ~/NoOpTweak
   - Purpose:
     Validate Theos compile/package path before touching real FakeGPS logic or the iPhone.
   - Initial project files:
     Makefile
     Tweak.xm
     control
     NoOpTweak.plist
   - Target:
     ARCHS = armv7
     TARGET = iphone:clang:latest:6.1
   - Current goal:
     Build/package only. No device install yet.

54. Confirmed active Theos/toolchain state:
   - THEOS:
     /home/bitcrusher32/theos
   - Theos exists with:
     makefiles/
     include/
     vendor/
     sdks/
     toolchain/
   - Existing legacy toolchain binaries are installed in /usr/bin:
     /usr/bin/arm-apple-darwin-ar
     /usr/bin/arm-apple-darwin-ld
     /usr/bin/arm-apple-darwin-as
     /usr/bin/ldid
   - Also present:
     /usr/bin/ios-clang
     /usr/bin/ios-clang++
     /usr/bin/ios-clang-wrapper
     /usr/bin/clang
     /usr/bin/clang++

55. First NoOpTweak failure: missing Theos compiler path:
   - Theos attempted to call:
     /home/bitcrusher32/theos/toolchain/linux/iphone/bin/clang
     /home/bitcrusher32/theos/toolchain/linux/iphone/bin/clang++
   - Failure:
     No such file or directory
   - Inspection showed:
     $THEOS/toolchain/linux/iphone/bin existed but was empty.
   - Initial fix attempted:
     symlinked Theos iphone bin tools to installed system tools:
       clang   -> /usr/bin/ios-clang
       clang++ -> /usr/bin/ios-clang++
       ar      -> /usr/bin/arm-apple-darwin-ar
       ld      -> /usr/bin/arm-apple-darwin-ld
       strip   -> /usr/bin/arm-apple-darwin-strip
       ranlib  -> /usr/bin/arm-apple-darwin-ranlib
       ldid    -> /usr/bin/ldid

56. ios-clang wrapper issue discovered:
   - NoOpTweak build hung at:
     clang -dumpversion
   - Process inspection showed Theos was blocked on:
     /home/bitcrusher32/theos/toolchain/linux/iphone/bin/clang -dumpversion
   - The symlink resolved to:
     /usr/bin/ios-clang
   - Inspecting /usr/bin/ios-clang with `head` printed binary garbage because:
     /usr/bin/ios-clang is a symlink to ios-clang-wrapper, an ELF binary.
   - Conclusion:
     No terminal/file encoding was corrupted.
     The wrong thing was inspected as text.
   - Fix attempted:
     Replace clang/clang++ symlinks with wrapper scripts that special-case:
       -dumpversion -> echo 18.1.3
     and otherwise delegate to:
       /usr/bin/ios-clang
       /usr/bin/ios-clang++

57. Second hang: ios-clang++ blocks during actual compile:
   - With -dumpversion fixed, Theos progressed to:
     Preprocessing Tweak.xm
     Compiling Tweak.xm (armv7)
   - Build hung inside:
     /usr/bin/ios-clang++
   - Process command showed a full compile invocation including:
     -target armv7-apple-ios6.1
     -isysroot /home/bitcrusher32/theos/sdks/iPhoneOS16.5.sdk
     -arch armv7
     -stdlib=libc++
   - Conclusion:
     Theos was now working far enough to compile, but ios-clang-wrapper itself was unsuitable/hanging in this path.

58. Replaced clang/clang++ wrappers to call system Clang directly:
   - New wrapper behavior:
     clang:
       -dumpversion -> echo 18.1.3
       otherwise exec /usr/bin/clang "$@"
     clang++:
       -dumpversion -> echo 18.1.3
       otherwise exec /usr/bin/clang++ "$@"
   - Rationale:
     Theos already supplies:
       -target armv7-apple-ios6.1
       -isysroot
       -arch armv7
     so the ios-clang-wrapper layer is not needed for this compile path.

59. NoOpTweak reached real compilation:
   - Theos successfully progressed through:
     Making all for tweak NoOpTweak
     Preprocessing Tweak.xm
     Compiling Tweak.xm (armv7)
   - First compile failure:
     Logos-generated constructor used:
       int __unused argc
       char __unused **argv
       char __unused **envp
     and __unused was not defined in this compile context.
   - Interpretation:
     Toolchain/Theos reached actual source compilation.
     The failure was caused by Logos/no-op constructor generation, not toolchain discovery.

60. Avoided Logos for initial smoke test:
   - Replaced Tweak.xm with plain C++ symbol:
     extern "C" void NoOpTweakMarker(void) {
         // No-op symbol for compile/link validation.
     }
   - Purpose:
     Validate compile/link/package path without Logos-generated code.
   - Result:
     Theos progressed past compilation and reached link stage.

61. Current no-op tweak linker blocker:
   - Build reached:
     Linking tweak NoOpTweak (armv7)
   - Failure:
     /usr/bin/ld: unrecognised emulation mode: llvm
     clang++: error: linker command failed with exit code 1
   - Interpretation:
     System clang++ compiled the object, but during link it selected Linux GNU /usr/bin/ld instead of the Darwin linker.
   - Existing Theos toolchain bin already has:
     ld -> /usr/bin/arm-apple-darwin-ld
   - Next fix:
     Make clang/clang++ wrappers pass:
       -B"$(dirname "$0")"
     so Clang searches Theos iphone bin first and picks the Darwin linker.

62. Updated wrappers for Darwin linker handoff:
   - User updated:
     $THEOS/toolchain/linux/iphone/bin/clang
     $THEOS/toolchain/linux/iphone/bin/clang++
   - New intended behavior:
     -dumpversion -> echo 18.1.3
     otherwise:
       exec /usr/bin/clang -B"$(dirname "$0")" "$@"
       exec /usr/bin/clang++ -B"$(dirname "$0")" "$@"
   - Purpose:
     Force compiler-driver link phase to discover:
       $THEOS/toolchain/linux/iphone/bin/ld
     which points to:
       /usr/bin/arm-apple-darwin-ld
   - Important:
     Retry has NOT yet been run after this wrapper update.

63. Theos reproducibility gap identified:
   - Toolchain reproducibility repo currently handles:
     building/installing legacy cctools/ios-tools
     smoke verification
   - It does not yet handle:
     wiring Theos to the installed toolchain.
   - Need to add a repo script after the wrapper strategy is validated:
     scripts/setup-theos-toolchain-links.sh
   - Expected script duties:
     create $THEOS/toolchain/linux/iphone/bin
     create clang and clang++ wrapper scripts
     create symlinks:
       ar      -> /usr/bin/arm-apple-darwin-ar
       ld      -> /usr/bin/arm-apple-darwin-ld
       strip   -> /usr/bin/arm-apple-darwin-strip
       ranlib  -> /usr/bin/arm-apple-darwin-ranlib
       ldid    -> /usr/bin/ldid
   - Do not commit this script until the no-op build confirms the wrapper strategy works.

Current state:
   - Toolchain reproducible build/install/verify: COMPLETE
   - Theos path discovery: FIXED manually
   - Theos compiler version probe: FIXED manually
   - Theos preprocessing: WORKING
   - Theos object compilation: WORKING with plain non-Logos Tweak.xm
   - Theos linking: IN PROGRESS
   - Current expected next command:
     cd ~/NoOpTweak
     make clean 2>&1 | tee clean-6.log
     make package 2>&1 | tee noop-build-6.log
   - If this fails:
     inspect noop-build-6.log for linker/sysroot/libSystem errors.
   - If this succeeds:
     add setup-theos-toolchain-links.sh to the Git repo and document no-op tweak validation.

Breakpoint note:
   - This is a strong checkpoint before the next linker retry.
   - No device install has occurred.
   - No real FakeGPS logic has been attempted.
   - All current work remains host-side and low risk to the iPhone.


64. Retried NoOpTweak after Darwin linker handoff wrapper update:
   - clang/clang++ wrappers were updated to call system Clang with:
     -B"$(dirname "$0")"
   - Purpose:
     Make Clang's link phase discover:
       $THEOS/toolchain/linux/iphone/bin/ld
     instead of Linux /usr/bin/ld.
   - Result:
     Linker handoff succeeded.
   - Previous error:
     /usr/bin/ld: unrecognised emulation mode: llvm
   - New error:
     ld: library not found for -lobjc
   - Interpretation:
     The build is now using the Darwin/Apple linker path, but the linker cannot resolve Objective-C runtime stubs/libs.

65. Tested explicit SDK usr/lib search path with iPhoneOS16.5 SDK:
   - Added to NoOpTweak Makefile:
     NoOpTweak_LDFLAGS += -L$(THEOS)/sdks/iPhoneOS16.5.sdk/usr/lib
   - Verified in verbose link command:
     -L/home/bitcrusher32/theos/sdks/iPhoneOS16.5.sdk/usr/lib
   - Result:
     Still failed:
       ld: library not found for -lobjc
   - Interpretation:
     The issue is not simply missing an SDK usr/lib search path.
     Likely problem:
       old arm-apple-darwin-ld cannot consume modern .tbd text-based stubs.

66. Inspected available SDK Objective-C stubs:
   - libobjc.tbd exists in multiple installed SDKs:
     iPhoneOS9.3.sdk
     iPhoneOS10.3.sdk
     iPhoneOS11.4.sdk
     iPhoneOS12.4.sdk
     iPhoneOS13.7.sdk
     iPhoneOS14.5.sdk
     iPhoneOS15.6.sdk
     iPhoneOS16.5.sdk
   - No confirmed libobjc.dylib import library was found in the SDKs during this phase.
   - Current suspicion:
     ld64 241.9 from this legacy toolchain does not recognize .tbd files as linkable libraries.

67. Tested iPhoneOS9.3 SDK:
   - Makefile changed from:
     TARGET = iphone:clang:latest:6.1
   - To:
     TARGET = iphone:clang:9.3:6.1
   - LDFLAGS changed to:
     -L$(THEOS)/sdks/iPhoneOS9.3.sdk/usr/lib
   - Initial compile failure:
     Modern Clang treated old SDK module.map naming as errors due to:
       -Werror
       -fmodules
       -fcxx-modules
   - Error class:
     module.map name is deprecated
     could not build module ObjectiveC / os / Dispatch / CoreFoundation / Foundation
   - Interpretation:
     This was a modern Clang modules compatibility issue with old SDK headers, not a direct linker problem.

68. Disabled Clang modules via wrappers:
   - clang/clang++ wrappers updated to strip module-related flags:
     -fmodules
     -fcxx-modules
     -fmodules-validate-once-per-build-session
     -fmodule-name=*
     -fbuild-session-file=*
     -fmodules-prune-after=*
     -fmodules-prune-interval=*
   - Wrappers still preserve:
     -dumpversion -> echo 18.1.3
     -B"$(dirname "$0")" for linker discovery
   - Result:
     iPhoneOS9.3 SDK compile progressed successfully again.
   - New/remaining failure:
     link still failed with:
       ld: library not found for -lobjc
   - Interpretation:
     Modules were a separate compile-time poison.
     After removing them, the underlying .tbd / library recognition issue remained.

69. Direct arm-apple-darwin-ld test performed:
   - Command used:
     arm-apple-darwin-ld \
       -arch armv7 \
       -dylib \
       -v \
       -o /tmp/noop-link-test.dylib \
       -L"$THEOS/sdks/iPhoneOS9.3.sdk/usr/lib" \
       -lobjc \
       .theos/obj/debug/armv7/*.o
   - Output:
     241.9
     configured to support archs: armv4t armv5 armv6 armv7 ...
     Library search paths:
       /home/bitcrusher32/theos/sdks/iPhoneOS9.3.sdk/usr/lib
       /usr/lib
       /usr/local/lib
     Framework search paths:
       /Library/Frameworks/
       /System/Library/Frameworks/
     ld: library not found for -lobjc
   - Result:
     /tmp/noop-link-test.dylib was not created.
   - Interpretation:
     Direct ld test confirms the issue is independent of Theos/Clang wrapper.
     arm-apple-darwin-ld searches the correct SDK path but does not treat libobjc.tbd as satisfying -lobjc.

70. Current key conclusion:
   - Theos compile pipeline is now mostly functional.
   - The current hard blocker is old ld64 vs SDK stub format:
     - libobjc.tbd exists
     - -L points at the directory containing it
     - direct ld still reports library not found
   - Therefore:
     The legacy ld likely needs classic Mach-O .dylib stubs/import libraries rather than .tbd text stubs, or a conversion/shim strategy.

71. Current NoOpTweak status:
   - Path:
     ~/NoOpTweak
   - Source:
     plain non-Logos Tweak.xm symbol:
       extern "C" void NoOpTweakMarker(void) { }
   - Compile:
     WORKING
   - Linker handoff:
     WORKING; Darwin ld64 is selected
   - Link:
     BLOCKED on libobjc resolution
   - Package:
     NOT REACHED
   - Device install:
     NOT ATTEMPTED

72. Candidate next directions:
   A. Test .tbd-to-.dylib symlink/copy experiment:
      - Create a temporary isolated SDK copy or backup.
      - Try symlink:
        libobjc.dylib -> libobjc.tbd
      - Low confidence, but quick to test whether ld uses filename extension only.
   B. Find or create old-style iPhoneOS SDK stubs:
      - Need real classic .dylib stub/import libs, especially:
        libobjc.dylib
        libSystem.dylib
        Foundation.framework/Foundation
        CoreFoundation.framework/CoreFoundation
      - Likely best long-term route for ld64 241.9.
   C. Investigate whether the toolchain has a tbd conversion utility:
      - Search for tapi, tbd, stub tools, or old cctools support.
   D. Try a lower-level dylib link that avoids Theos default -lobjc/Foundation/CoreFoundation:
      - Useful to separate pure Mach-O dylib linking from Objective-C/framework linking.
      - But real tweaks will eventually need objc/Foundation/Substrate, so this is only a diagnostic path.
   E. Consider using newer LLVM lld for linking:
      - Riskier because the project relies on old cctools behavior and iOS 6 compatibility.
      - Could solve .tbd support but introduce Mach-O/deployment compatibility issues.

73. Recommended next immediate step:
   - Do not broad-hack all libraries yet.
   - First perform a contained experiment:
     1. Inspect libobjc.tbd format.
     2. Test whether ld accepts libobjc.dylib symlinked to libobjc.tbd.
     3. If not, search for any actual .dylib/.a SDK stubs in Theos or old SDK folders.
   - Keep all experiments reversible.
   - Prefer testing inside a copied SDK or with explicit temporary paths.

Current state:
   - Toolchain reproducible build/install/verify: COMPLETE
   - Theos wrapper pathing: MANUALLY WORKING
   - Theos compile: WORKING
   - Theos link: BLOCKED by .tbd/libobjc incompatibility
   - Current verified linker:
     arm-apple-darwin-ld 241.9
   - Current blocker:
     cannot satisfy -lobjc from .tbd-based SDKs

Breakpoint note:
   - This checkpoint captures the transition from Theos/toolchain discovery problems to a precise SDK/library-format blocker.
   - No device install has occurred.
   - No real FakeGPS logic has been attempted.
   - The iPhone remains untouched and safe.


74. Added temporary libSystem overlay:
   - Earlier overlay created temporary `.dylib` filenames pointing to `.tbd` files for:
     libobjc.dylib
     Foundation.framework/Foundation
     CoreFoundation.framework/CoreFoundation
   - New step added:
     libSystem.dylib -> $THEOS/sdks/iPhoneOS9.3.sdk/usr/lib/libSystem.tbd
   - Purpose:
     Continue the contained overlay experiment to see how far Theos packaging can proceed with old ld64 and .tbd-backed names.

75. Retried NoOpTweak with expanded overlay:
   - Command:
     make package messages=yes
   - Build progressed through:
     - Preprocessing Tweak.xm
     - Compiling Tweak.xm for armv7
     - Linking NoOpTweak.dylib
   - Previous blocker:
     ld: library not found for -lSystem
   - New result:
     ld produced an armv7 NoOpTweak.dylib at:
       ./.theos/obj/debug/armv7/NoOpTweak.dylib
   - Observed file:
       ./.theos/obj/debug/armv7/NoOpTweak.dylib
       size about 33116 bytes
   - This is the first actual NoOpTweak dylib emission from Theos.

76. Important overlay warnings during link:
   - ld warned that it was ignoring several overlay files because they are text `.tbd` files masquerading as classic Mach-O filenames:
     - libobjc.dylib
     - Foundation.framework/Foundation
     - CoreFoundation.framework/CoreFoundation
     - libSystem.dylib
   - Warning class:
     unsupported file format beginning with bytes:
       0x2D 0x2D 0x2D 0x0A ...
     which corresponds to the YAML/text `.tbd` header.
   - Interpretation:
     The overlay trick works as a filename-discovery bypass only.
     It does not make old ld64 actually consume `.tbd` contents.
   - Because the current no-op object has no real external ObjC/Foundation/CoreFoundation/libSystem symbol references, ld can still emit a dylib while ignoring those pseudo-stubs.

77. New blocker: signing phase:
   - After linking, Theos copied:
       .theos/obj/debug/armv7/NoOpTweak.dylib
     to an unsigned intermediate:
       .theos/obj/debug/NoOpTweak.dylib.<hash>.unsigned
   - Theos then attempted signing:
       CODESIGN_ALLOCATE=/home/bitcrusher32/theos/toolchain/linux/iphone/bin/codesign_allocate ldid -S ...
   - Failure:
       ldid.cpp(588): _assert(2:false)
       ldid.cpp(594): _assert(0:WEXITSTATUS(status) == 0)
   - Result:
     Packaging failed after link, during signing.
   - The unsigned/intermediate was removed by make cleanup, but the architecture-specific dylib remained:
       .theos/obj/debug/armv7/NoOpTweak.dylib

78. Current meaning of the progress:
   - Toolchain + Theos can now:
     - preprocess
     - compile
     - invoke Darwin linker
     - emit an armv7 Mach-O dylib for a no-op object
   - The build still cannot package successfully because signing fails.
   - Current emitted dylib is not evidence of real ObjC/Foundation compatibility because linked SDK `.tbd` files were ignored.
   - However, it is a major host-side pipeline milestone:
     first generated tweak dylib from Theos using the patched legacy toolchain environment.

79. Current suspected signing issue:
   - Theos sets:
       CODESIGN_ALLOCATE=/home/bitcrusher32/theos/toolchain/linux/iphone/bin/codesign_allocate
   - The toolchain bin has wrappers/symlinks for clang/clang++/ar/ld/strip/ranlib/ldid, but codesign_allocate may be missing, invalid, or not compatible.
   - ldid likely invokes or depends on CODESIGN_ALLOCATE and asserts when that helper fails.
   - Next inspection should check:
       ls -la "$THEOS/toolchain/linux/iphone/bin/codesign_allocate"
       which codesign_allocate
       find /usr/bin /usr/local/bin "$THEOS" -name 'codesign_allocate' -type f -o -type l
       ldid -S .theos/obj/debug/armv7/NoOpTweak.dylib
     optionally with CODESIGN_ALLOCATE unset or pointed to a valid helper.
   - Do not install this dylib or any package on device yet.

80. Current tactical options:
   A. Fix signing path:
      - Find or symlink a valid codesign_allocate.
      - Or test ldid without CODESIGN_ALLOCATE if supported.
      - Goal: get Theos to complete package generation for a no-op dylib.
   B. Temporarily disable signing:
      - Useful only to test package assembly.
      - Not enough for device install.
   C. Continue real linker-stub work:
      - Needed before meaningful ObjC/FakeGPS tweak logic.
      - Requires real Mach-O stubs or a linker capable of `.tbd`.
   D. Preserve the current no-op dylib:
      - Copy `.theos/obj/debug/armv7/NoOpTweak.dylib` somewhere before future clean steps if desired.

81. Updated current state:
   - Toolchain reproducible build/install/verify: COMPLETE
   - Theos wrapper pathing: MANUALLY WORKING
   - Theos compile: WORKING
   - Darwin linker handoff: WORKING
   - No-op armv7 dylib emission: WORKING with overlay caveats
   - Theos package/signing: BLOCKED at ldid/codesign_allocate
   - Real ObjC/Foundation linking: NOT SOLVED; `.tbd` files are still ignored by old ld64
   - Device install: NOT ATTEMPTED

82. Recommended next immediate step:
   - Pause broad linker/library hacks.
   - Inspect and fix signing path first, because it is the current packaging blocker after dylib emission.
   - Then decide whether to:
     1. complete a no-op `.deb` package milestone with clear caveats, or
     2. return to real SDK stub/linker compatibility for meaningful tweak logic.

Breakpoint note:
   - This is a valuable breakpoint.
   - The project has moved from "cannot link" to "dylib emitted, signing fails."
   - The overlay experiment should remain documented as a diagnostic hack, not a production fix.
   - No device install has occurred.


83. Signing investigation isolated CODESIGN_ALLOCATE behavior:
   - Existing emitted dylib:
     .theos/obj/debug/armv7/NoOpTweak.dylib
   - File identified as:
     Mach-O armv7 dynamically linked shared library
   - Size before manual signing:
     about 33116 bytes.
   - Manual ldid test with CODESIGN_ALLOCATE unset:
     unset CODESIGN_ALLOCATE
     ldid -S /tmp/NoOpTweak.sign-test.unset.dylib
   - Result:
     No error output.
     Signed test file size grew to about 33456 bytes.
   - Manual ldid test with CODESIGN_ALLOCATE empty/set:
     CODESIGN_ALLOCATE= ldid -S /tmp/NoOpTweak.sign-test.empty.dylib
   - Result:
     ldid emitted assertions:
       ldid.cpp(588): _assert(2:false)
       ldid.cpp(594): _assert(0:WEXITSTATUS(status) == 0)
   - Interpretation:
     ldid works on this dylib when CODESIGN_ALLOCATE is unset.
     The Theos signing failure is caused by the CODESIGN_ALLOCATE environment path/behavior, not by a total inability to sign the dylib.

84. Replaced Theos ldid symlink with wrapper:
   - Path:
     $THEOS/toolchain/linux/iphone/bin/ldid
   - New wrapper behavior:
     unset CODESIGN_ALLOCATE
     exec /usr/bin/ldid "$@"
   - Purpose:
     Override Theos' inline:
       CODESIGN_ALLOCATE=... ldid -S ...
     by ensuring the ldid process itself unsets CODESIGN_ALLOCATE before delegating to the real ldid.
   - Package retry was run with:
     PATH="$THEOS/toolchain/linux/iphone/bin:$PATH" make package messages=yes
   - Result:
     Theos should now call the wrapper ldid first.

85. NoOpTweak package retry after ldid wrapper:
   - Build still emits the expected overlay warnings:
     - libobjc.dylib ignored because it is actually a .tbd text file
     - Foundation.framework/Foundation ignored because it is actually a .tbd text file
     - CoreFoundation.framework/CoreFoundation ignored because it is actually a .tbd text file
     - libSystem.dylib ignored because it is actually a .tbd text file
   - These warnings remain expected for the temporary overlay diagnostic hack.
   - The build progressed past link and into signing again.
   - The exact final package status from the attached terminal output was partially truncated in the provided file preview, but the visible evidence shows major progress beyond the previous CODESIGN_ALLOCATE failure path.
   - Follow-up required:
     Inspect the complete noop-build-16.log and run:
       find . -maxdepth 7 -type f \( -name "*.deb" -o -name "*.dylib" \) -ls
     to confirm whether a .deb was produced.

86. Current interpretation after signing work:
   - ldid itself is usable on the emitted no-op dylib if CODESIGN_ALLOCATE is not set.
   - Theos' default signing invocation can be made compatible by using an ldid wrapper that unsets CODESIGN_ALLOCATE.
   - The no-op dylib remains a host-side proof artifact only because real ObjC/Foundation/System link correctness is not solved.
   - The next meaningful branch is now:
     A. Confirm whether package generation completed after the ldid wrapper.
     B. If package completed, record a "no-op .deb packaging achieved with overlay caveats" milestone.
     C. Then return to real ObjC/Foundation/libSystem linking with proper Mach-O stubs or an alternate linker.

87. Updated unresolved technical debt:
   - Temporary overlay hack:
     ~/ios-sdk-lib-overlay/iPhoneOS9.3
     is not a real SDK solution.
   - It only provides .dylib/framework filenames pointing at .tbd text files.
   - Old ld64 ignores these files as unsupported format.
   - The no-op dylib links only because the source does not reference real runtime symbols.
   - Real FakeGPS work will require a real solution for:
     libobjc
     libSystem
     Foundation
     CoreFoundation
     MobileSubstrate / CydiaSubstrate
   - Likely routes:
     - find/acquire old-style Mach-O SDK stubs compatible with ld64 241.9
     - generate minimal compatible stubs
     - or evaluate a newer Mach-O linker path carefully.

88. Recommended next step:
   - Before grinding ObjC/Foundation:
     1. Confirm whether noop-build-16.log produced a .deb.
     2. Preserve the exact current wrapper files:
        $THEOS/toolchain/linux/iphone/bin/clang
        $THEOS/toolchain/linux/iphone/bin/clang++
        $THEOS/toolchain/linux/iphone/bin/ldid
        $THEOS/toolchain/linux/iphone/bin/codesign_allocate
     3. If package completed, add a reproduction script to the Git repo for Theos wrapper setup.
     4. Then start a separate real-linking investigation for ObjC/Foundation, without conflating it with no-op packaging mechanics.

Current state:
   - Toolchain reproducible build/install/verify: COMPLETE
   - Theos wrapper pathing: MANUALLY WORKING
   - Theos compile: WORKING
   - Darwin linker handoff: WORKING
   - No-op armv7 dylib emission: WORKING with overlay caveats
   - Manual ldid signing with CODESIGN_ALLOCATE unset: WORKING
   - Theos signing wrapper fix: APPLIED
   - .deb package status: NEEDS FINAL CONFIRMATION FROM COMPLETE LOG / FIND OUTPUT
   - Real ObjC/Foundation linking: NOT SOLVED

Breakpoint note:
   - This is an appropriate checkpoint before deeper ObjC/Foundation work.
   - The project now has a clear separation between:
     packaging pipeline mechanics
     and real SDK/framework link compatibility.
   - No device install has occurred.


89. Confirmed no-op Theos .deb package milestone:
   - Project:
     ~/NoOpTweak
   - Confirmed package artifact:
     ./packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb
   - Confirmed staged/signed dylibs:
     ./.theos/_/Library/MobileSubstrate/DynamicLibraries/NoOpTweak.dylib
     ./.theos/obj/debug/NoOpTweak.dylib
     ./.theos/obj/debug/armv7/NoOpTweak.dylib
   - Build log reached:
     dm.pl: building package `com.bitcrusher32.nooptweak:iphoneos-arm'
   - Interpretation:
     The host-side Theos pipeline can now:
       - compile
       - link
       - sign
       - stage
       - package
     a no-op ARMv7 tweak into a .deb.
   - Caveat:
     This no-op package still used the .tbd overlay diagnostic hack and does not prove real Objective-C/Foundation linking.

90. Repository checkpoint after no-op package milestone:
   - README was updated to document the no-op package milestone.
   - The repo now documents that:
     - ARMv7 tweak object compilation works
     - Darwin linker handoff through Theos wrappers works
     - ldid signing works through a wrapper that unsets CODESIGN_ALLOCATE
     - .deb package creation works
   - README caveat added:
     The no-op package proves host-side package mechanics, not real Objective-C/Foundation/Substrate linking correctness.
   - User reported commit/push completed before starting ObjC/Foundation work.

91. Started real Objective-C runtime linking investigation:
   - New clean test project:
     ~/ObjCRuntimeTest
   - Purpose:
     Force a real Objective-C runtime symbol and stop relying on the no-op path.
   - Test source:
     extern "C" void *objc_getClass(const char *name);
     extern "C" void ObjCRuntimeTestMarker(void) {
         volatile void *cls = objc_getClass("NSObject");
         (void)cls;
     }
   - Target:
     ARCHS = armv7
     TARGET = iphone:clang:9.3:6.1
   - Build used the same temporary overlay/library paths as the no-op test.
   - Expected result:
     Fail on a real ObjC runtime unresolved symbol if .tbd overlays are insufficient.

92. ObjCRuntimeTest first result:
   - Compile succeeded.
   - Link failed.
   - Failure:
     Undefined symbols for architecture armv7:
       "_objc_getClass", referenced from:
           _ObjCRuntimeTestMarker in Tweak.xm.<hash>.o
   - Existing overlay warnings appeared again:
     libobjc.dylib ignored because it was actually a .tbd text file
     Foundation.framework/Foundation ignored because it was actually a .tbd text file
     CoreFoundation.framework/CoreFoundation ignored because it was actually a .tbd text file
     libSystem.dylib ignored because it was actually a .tbd text file
   - Interpretation:
     This confirmed the no-op package succeeded only because no real runtime symbols were referenced.
     Real Objective-C linking requires usable Mach-O stubs or a linker with .tbd support.

93. Created first real Mach-O libobjc stub:
   - Stub directory:
     ~/ios-sdk-machostubs/iPhoneOS9.3/usr/lib
   - Source:
     libobjc_stub.s
   - Initial symbol:
     _objc_getClass
   - Built using:
     arm-apple-darwin-as -arch armv7
     arm-apple-darwin-ld -arch armv7 -dylib -install_name /usr/lib/libobjc.A.dylib
   - Output:
     ~/ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libobjc.dylib
   - Verification:
     file reported:
       Mach-O armv7 dynamically linked shared library
     nm reported:
       00000ffc T _objc_getClass
   - Interpretation:
     A real Mach-O dylib stub can be generated locally with the recovered toolchain.

94. First libobjc Mach-O stub integration attempt:
   - Added:
     -L$(HOME)/ios-sdk-machostubs/iPhoneOS9.3/usr/lib
     to ObjCRuntimeTest LDFLAGS.
   - Problem:
     The new -L appeared after Theos' default -lobjc in the final link command.
   - Result:
     ld still used the earlier .tbd overlay path for -lobjc, ignored it, and did not resolve _objc_getClass.
   - Fix approach:
     Put the Mach-O stub path earlier via the clang++ wrapper instead of relying on late project LDFLAGS.

95. Forced Mach-O stub path earlier through clang++ wrapper:
   - Modified:
     $THEOS/toolchain/linux/iphone/bin/clang++
   - Added before "${args[@]}":
     -L"$HOME/ios-sdk-machostubs/iPhoneOS9.3/usr/lib"
   - Purpose:
     Ensure ld sees real Mach-O libobjc/libSystem stubs before the .tbd overlay paths when resolving Theos' default -lobjc and later -lSystem behavior.
   - Result:
     _objc_getClass unresolved error disappeared.
   - New failure:
     ld: symbol dyld_stub_binder not found (normally in libSystem.dylib).
   - Interpretation:
     ld accepted the Mach-O libobjc stub and attempted lazy binding, but needed a usable Mach-O libSystem stub.

96. Created real Mach-O libSystem stub:
   - Stub file:
     ~/ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libSystem.dylib
   - Source:
     libSystem_stub.s
   - Symbol:
     dyld_stub_binder
   - Built using:
     arm-apple-darwin-as -arch armv7
     arm-apple-darwin-ld -arch armv7 -dylib -install_name /usr/lib/libSystem.B.dylib
   - Purpose:
     Satisfy dyld_stub_binder for lazy-binding stubs generated during ObjC runtime calls.
   - Result:
     ObjCRuntimeTest progressed past the dyld_stub_binder failure.

97. ObjCRuntimeTest package milestone:
   - After adding real Mach-O libobjc and libSystem stubs, ObjCRuntimeTest built successfully enough to package.
   - Build progressed through:
     - preprocessing
     - compiling
     - linking
     - signing
     - staging
     - .deb creation
   - Confirmed artifacts:
     ./.theos/obj/debug/armv7/ObjCRuntimeTest.dylib
     ./.theos/obj/debug/ObjCRuntimeTest.dylib
     ./.theos/_/Library/MobileSubstrate/DynamicLibraries/ObjCRuntimeTest.dylib
     ./packages/com.bitcrusher32.objcruntimetest_0.0.1-1+debug_iphoneos-arm.deb
   - Build log reached:
     dm.pl: building package `com.bitcrusher32.objcruntimetest:iphoneos-arm'
   - This is the first package milestone that intentionally references a real Objective-C runtime symbol.

98. Remaining warnings after ObjCRuntimeTest success:
   - The build still warned that the Foundation and CoreFoundation overlay files were ignored:
     Foundation.framework/Foundation is still a .tbd text file
     CoreFoundation.framework/CoreFoundation is still a .tbd text file
   - This is expected because ObjCRuntimeTest only needed objc_getClass plus libSystem lazy-binding support.
   - Interpretation:
     Objective-C runtime minimal linking is now partially solved via Mach-O stubs.
     Foundation/CoreFoundation real symbol linking is not yet solved.

99. Current technical conclusion:
   - Old ld64 241.9 cannot consume modern .tbd text stubs.
   - Filename overlays can move past "library not found" or "framework not found" only for no-op/no-symbol cases, but ld ignores them as unsupported file format.
   - Real Mach-O dylib stubs work.
   - The viable path is now:
     Generate real ARMv7 Mach-O stubs for the runtime/framework symbols required by test projects and eventually FakeGPS.
   - Confirmed viable so far:
     libobjc.dylib stub exporting _objc_getClass
     libSystem.dylib stub exporting dyld_stub_binder

100. Current project state after ObjCRuntimeTest:
   - Toolchain reproducible build/install/verify: COMPLETE
   - Theos wrapper setup: WORKING
   - No-op .deb package: COMPLETE with overlay caveats
   - Objective-C runtime symbol test package: COMPLETE with Mach-O libobjc/libSystem stubs
   - Foundation/CoreFoundation real stubs: NOT SOLVED
   - MobileSubstrate/CydiaSubstrate real stubs: NOT SOLVED
   - Device install: NOT ATTEMPTED
   - FakeGPS logic: NOT STARTED

101. Recommended next step:
   - Commit/push documentation and wrapper/stub-generation scripts before proceeding.
   - Add a reproducible script for Mach-O SDK stub generation:
     scripts/build-ios-machostubs.sh
   - The script should initially generate:
     ~/ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libobjc.dylib
     ~/ios-sdk-machostubs/iPhoneOS9.3/usr/lib/libSystem.dylib
   - Update setup-theos-toolchain-links.sh or documentation to ensure clang++ includes the Mach-O stub path early.
   - Then begin Foundation/CoreFoundation tests:
     First CoreFoundation-only:
       CFStringCreateWithCString or another small CF symbol
     Then Foundation:
       NSString / NSClassFromString / NSLog-like behavior as a controlled test
   - Keep all tests host-side until a harmless install/uninstall process is deliberately validated.

Breakpoint note:
   - This is a very strong checkpoint.
   - The project has moved from no-op packaging to a real Objective-C runtime link/package proof.
   - The next mountain is framework stub generation, not basic toolchain/Theos functionality.
   - No device install has occurred.


102. Began CoreFoundation framework stub investigation:
   - New clean test project:
     ~/CoreFoundationTest
   - Purpose:
     Force real CoreFoundation symbols before attempting Foundation.
   - Initial test target:
     ARCHS = armv7
     TARGET = iphone:clang:9.3:6.1
   - Initial source attempted to manually typedef:
     CFStringRef
     CFStringEncoding
     CFStringCreateWithCString
   - Result:
     Compile failed because CoreFoundation SDK headers were already being included through Theos/Prefix.pch.
   - Error class:
     typedef redefinition / conflicting declaration.
   - Interpretation:
     SDK headers are reachable and active during compile.
     The failure was caused by redundant hand declarations, not missing headers or linker state.

103. Corrected CoreFoundationTest to use real SDK headers:
   - Replaced manual typedefs with:
     #include <CoreFoundation/CoreFoundation.h>
   - Test function:
     CFStringCreateWithCString(
       kCFAllocatorDefault,
       "legacy-ios-toolchain-test",
       kCFStringEncodingUTF8
     )
   - Result:
     Compile succeeded.
     Link failed as expected on real CoreFoundation symbols.
   - Missing symbols:
     _CFStringCreateWithCString
     _kCFAllocatorDefault
   - Existing warning:
     CoreFoundation.framework/CoreFoundation from .tbd overlay was ignored as unsupported text format.
   - Interpretation:
     This confirmed the exact first CoreFoundation symbols needed in a real Mach-O framework stub.

104. Generated real Mach-O CoreFoundation.framework stub:
   - Stub path:
     ~/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
   - Source:
     CoreFoundation_stub.s
   - Symbols added:
     _CFStringCreateWithCString
     _kCFAllocatorDefault
   - Stub behavior:
     _CFStringCreateWithCString returns NULL/0 as a linker-only placeholder.
     _kCFAllocatorDefault is exported as data with a zero value.
   - Built using:
     arm-apple-darwin-as -arch armv7
     arm-apple-darwin-ld -arch armv7 -dylib
       -install_name /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
   - Purpose:
     Provide old ld64 with a real Mach-O framework binary instead of an unsupported .tbd file.

105. Found framework header lookup side-effect:
   - Added early framework search path through wrappers:
     -F"$HOME/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks"
   - Result:
     Clang began resolving CoreFoundation.framework from the machostubs directory first.
   - New compile failure:
     Foundation.h included:
       <CoreFoundation/CoreFoundation.h>
     but the stub framework had no Headers directory.
   - Error:
     fatal error: 'CoreFoundation/CoreFoundation.h' file not found
   - Interpretation:
     Framework stubs need both:
       a Mach-O framework binary for link time
       a Headers symlink to real SDK headers for compile time

106. Fixed CoreFoundation.framework stub headers:
   - Added symlink:
     ~/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/CoreFoundation.framework/Headers
     ->
     $THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/CoreFoundation.framework/Headers
   - Purpose:
     Allow early -F machostubs path to satisfy framework binary lookup without breaking header lookup.
   - Result:
     CoreFoundationTest compile resumed successfully.

107. CoreFoundationTest package milestone:
   - After adding:
     - real Mach-O CoreFoundation.framework/CoreFoundation stub
     - Headers -> real SDK Headers symlink
     CoreFoundationTest built successfully enough to package.
   - Build progressed through:
     - preprocessing
     - compiling
     - linking
     - signing
     - staging
     - .deb creation
   - Confirmed artifacts:
     ./.theos/obj/debug/armv7/CoreFoundationTest.dylib
     ./.theos/obj/debug/CoreFoundationTest.dylib
     ./.theos/_/Library/MobileSubstrate/DynamicLibraries/CoreFoundationTest.dylib
     ./packages/com.bitcrusher32.corefoundationtest_0.0.1-1+debug_iphoneos-arm.deb
   - Build log reached:
     dm.pl: building package `com.bitcrusher32.corefoundationtest:iphoneos-arm'
   - This is the first package milestone that intentionally references real CoreFoundation symbols.

108. Remaining warning after CoreFoundationTest success:
   - The build still warns:
     Foundation.framework/Foundation is ignored because it is still a .tbd text-file overlay.
   - This warning is expected because no real Foundation Mach-O framework stub has been generated yet.
   - Interpretation:
     CoreFoundation baseline is now solved at the linker/package-proof level.
     Foundation remains the next unresolved framework layer.

109. Updated stub strategy conclusion:
   - For frameworks, the working pattern is:
     1. Create real ARMv7 Mach-O framework binary at:
        FrameworkName.framework/FrameworkName
     2. Add exported symbols as needed for the current test.
     3. Add:
        Headers -> real SDK FrameworkName.framework/Headers
     4. Ensure the machostubs framework path appears early in compiler/linker invocation.
   - This avoids:
     - old ld64 ignoring .tbd files
     - Clang breaking on missing headers due to early -F path

110. Current validated ladder:
   - Toolchain reproducible build/install/verify: COMPLETE
   - Theos wrapper setup: WORKING
   - No-op .deb package: COMPLETE with overlay caveats
   - Objective-C runtime symbol test package: COMPLETE with Mach-O libobjc/libSystem stubs
   - CoreFoundation symbol test package: COMPLETE with Mach-O CoreFoundation framework stub
   - Foundation real stubs: NOT SOLVED
   - MobileSubstrate/CydiaSubstrate real stubs: NOT SOLVED
   - Device install: NOT ATTEMPTED
   - FakeGPS logic: NOT STARTED

111. Recommended next steps:
   - Commit/push documentation and script updates before proceeding.
   - Update scripts/build-ios-machostubs.sh to generate:
     - libobjc.dylib stub with _objc_getClass
     - libSystem.dylib stub with dyld_stub_binder
     - CoreFoundation.framework/CoreFoundation stub with:
       _CFStringCreateWithCString
       _kCFAllocatorDefault
     - CoreFoundation.framework/Headers symlink to the real SDK headers
   - Update docs/MACHO_STUBS.md to record:
     - .tbd overlays are only diagnostic
     - framework stubs require Headers symlinks
     - CoreFoundationTest package now validates first CoreFoundation symbols
   - Then proceed to FoundationTest:
     likely first symbols include Foundation/NSString/NSLog or class/runtime access depending on chosen test.
   - Keep all testing host-side until harmless install/uninstall is deliberately validated.

Breakpoint note:
   - This is a strong checkpoint.
   - The project has now moved from Objective-C runtime stubs to a working CoreFoundation framework stub.
   - The remaining next mountain is Foundation, not the base toolchain/package pipeline.
   - No device install has occurred.


112. Began Foundation framework stub investigation:
   - New clean test project:
     ~/FoundationTest
   - Purpose:
     Force a real Foundation symbol after validating ObjC runtime and CoreFoundation.
   - Initial test source:
     #import <Foundation/Foundation.h>
     extern "C" void FoundationTestMarker(void) {
         volatile Class cls = NSClassFromString(@"NSObject");
         (void)cls;
     }
   - Target:
     ARCHS = armv7
     TARGET = iphone:clang:9.3:6.1
   - Expected result:
     Compile should succeed, then link should fail on first real Foundation symbols because Foundation.framework/Foundation was still only a .tbd overlay.

113. FoundationTest first linker failure:
   - Compile succeeded.
   - Link failed as expected.
   - Missing symbols:
     _NSClassFromString
     ___CFConstantStringClassReference
   - Existing warning:
     Foundation.framework/Foundation from the .tbd overlay was ignored as unsupported text format.
   - Interpretation:
     The first Foundation stub surface was identified.
     The constant string reference came from the Objective-C string literal:
       @"NSObject"

114. Generated real Mach-O Foundation.framework stub:
   - Stub path:
     ~/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks/Foundation.framework/Foundation
   - Source:
     Foundation_stub.s
   - Symbols added:
     _NSClassFromString
     ___CFConstantStringClassReference
   - Stub behavior:
     _NSClassFromString returns NULL/0 as a linker-only placeholder.
     ___CFConstantStringClassReference is exported as zero-valued data.
   - Built using:
     arm-apple-darwin-as -arch armv7
     arm-apple-darwin-ld -arch armv7 -dylib
       -install_name /System/Library/Frameworks/Foundation.framework/Foundation
   - Verification:
     file reported Foundation as a Mach-O armv7 dynamically linked shared library.
     nm reported:
       00000ff8 T _NSClassFromString
       00001000 D ___CFConstantStringClassReference
   - Added header symlink:
     Foundation.framework/Headers
     ->
     $THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/Foundation.framework/Headers

115. Foundation header nullability compile issue:
   - After adding the real Foundation framework stub and Headers symlink, compile moved backward into modern-Clang header diagnostics.
   - Failure class:
     old iOS 9.3 Foundation headers triggered nullability warnings treated as errors by Theos' -Werror.
   - Errors included:
     -Wnullability-inferred-on-nested-type
     -Wnullability-completeness-on-arrays
     fatal error: too many errors emitted
   - Affected headers included:
     NSEnumerator.h
     NSArray.h
     NSDictionary.h
   - Interpretation:
     The Foundation stub itself was structurally valid.
     The new blocker was a compile-time modern-Clang compatibility issue, not a linker-symbol issue.

116. Suppressed modern Clang nullability warnings in wrappers:
   - Updated:
     $THEOS/toolchain/linux/iphone/bin/clang
     $THEOS/toolchain/linux/iphone/bin/clang++
   - Added wrapper-level arguments:
     -Wno-nullability-inferred-on-nested-type
     -Wno-nullability-completeness-on-arrays
     -Wno-nullability-completeness
   - Purpose:
     Prevent old SDK Foundation headers from failing under modern Clang + Theos -Werror.
   - This follows the earlier pattern where wrappers already stripped module flags incompatible with old SDKs.

117. FoundationTest package milestone:
   - After Foundation Mach-O stub generation and nullability warning suppressions, FoundationTest completed:
     - preprocessing
     - compiling
     - linking
     - signing
     - staging
     - .deb creation
   - Confirmed artifacts:
     ./.theos/obj/debug/armv7/FoundationTest.dylib
     ./.theos/obj/debug/FoundationTest.dylib
     ./.theos/_/Library/MobileSubstrate/DynamicLibraries/FoundationTest.dylib
     ./packages/com.bitcrusher32.foundationtest_0.0.1-1+debug_iphoneos-arm.deb
   - Build log reached:
     dm.pl: building package `com.bitcrusher32.foundationtest:iphoneos-arm'
   - This is the first package milestone that intentionally references real Foundation symbols.

118. Updated validated ladder:
   - No-op package:
     COMPLETE
   - Objective-C runtime symbol package:
     COMPLETE with Mach-O libobjc/libSystem stubs
   - CoreFoundation symbol package:
     COMPLETE with Mach-O CoreFoundation framework stub and Headers symlink
   - Foundation symbol package:
     COMPLETE with Mach-O Foundation framework stub, Headers symlink, and nullability warning suppressions
   - MobileSubstrate/CydiaSubstrate real stubs:
     NOT SOLVED
   - Logos hook compile path:
     NOT REVALIDATED after wrapper improvements
   - Device install:
     NOT ATTEMPTED
   - FakeGPS logic:
     NOT STARTED

119. Current practical meaning:
   - The host-side linker/package pipeline now supports a minimal Foundation-based tweak test.
   - The generated framework stubs remain linker-only host artifacts.
   - They do not provide runtime implementations.
   - On-device runtime behavior would depend on the real iOS 6.1.3 frameworks and dyld resolving install names.
   - Current generated test packages should still be treated as host validation artifacts, not production/device-ready tweaks.

120. Current unresolved technical debt:
   - The wrapper setup script and stub generation script must be updated to reproduce:
     - Foundation.framework/Foundation stub
     - Foundation.framework/Headers symlink
     - nullability warning suppressions
   - docs/MACHO_STUBS.md should be updated to include Foundation status.
   - A new docs/FOUNDATION_STUBS.md should record the first Foundation symbol set and the nullability suppression requirement.
   - The current source tests live outside the repo in home-directory throwaway test projects.
   - Optional future repo examples could preserve minimal test projects:
     examples/noop-tweak/
     examples/objc-runtime-test/
     examples/corefoundation-test/
     examples/foundation-test/

121. Recommended next steps:
   - Commit/push Foundation docs and script updates.
   - Then choose next milestone:
     A. MobileSubstrate/CydiaSubstrate link test.
     B. Revalidate Logos-generated hook compilation now that wrappers suppress modules/nullability and can link Foundation.
     C. Build a harmless install/uninstall no-op package test plan before touching the real iPhone.
   - Recommendation:
     Do not install anything on the iPhone yet.
     First solve MobileSubstrate/Logos host-side packaging, then deliberately plan a harmless install/uninstall dry run.

Breakpoint note:
   - This is a major checkpoint.
   - The project has now moved from base framework stubs to Foundation-level host packaging.
   - The next mountain is Substrate/Logos/device-safety workflow, not Foundation.
   - No device install has occurred.


122. Repo cleanup/restructure review started after Foundation milestone:
   - User requested a cleanup pass before continuing toolchain/Substrate/Logos work.
   - Context:
     Another GPT reviewed the repo and identified synchronization gaps between:
       - the LogDoc truth
       - the checked-in repo truth
       - the current tested WSL/Theos state
   - Main critique accepted:
     The repo had become technically useful but confusing at the front door.
     Some docs still described older unvalidated states even though no-op, ObjC runtime, CoreFoundation, and Foundation host packages had since been validated.
   - Decision:
     Treat this as a documentation/reproducibility hardening pass, not a new feature branch.

123. Cleanup priority order established:
   - Priority 1:
     Bring scripts into sync with validated reality.
     In particular:
       scripts/build-ios-machostubs.sh needed Foundation.framework/Foundation generation.
   - Priority 2:
     Fix stale front-door documentation.
     README/PATCHES/MACHO_STUBS needed to reflect the current validated ladder.
   - Priority 3:
     Quarantine misleading old patches/*.patch sketches.
   - Priority 4:
     Add a single current-state doc for future readers.
   - Priority 5:
     After cleanup, return to the technical path:
       Logos revalidation
       MobileSubstrate/CydiaSubstrate link tests
       harmless install/uninstall planning
       FakeGPS MVP later

124. Cleanup scripts/pipeline generated:
   - Temporary script phases were generated under /tmp:
     /tmp/00-repo-cleanup-preflight.sh
     /tmp/01-sync-foundation-stubs.sh
     /tmp/02-refresh-current-docs.sh
     /tmp/03-quarantine-obsolete-patches.sh
     /tmp/04-cleanup-sanity-check.sh
     /tmp/05-commit-cleanup.sh
   - Purpose:
     Keep each repo cleanup stage controlled, reviewable, and commit-friendly.
   - Important workflow rule:
     Do not run the push phase until the sanity-check phase is reviewed.

125. Phase 4 cautionary review found two blockers:
   - User stopped before committing/pushing and provided Phase 4 output.
   - Blocker 1:
     scripts/__pycache__/ appeared after python3 -m py_compile.
   - Fix:
     Remove scripts/__pycache__/ and add Python cache ignores to .gitignore:
       __pycache__/
       *.pyc
   - Blocker 2:
     scripts/build-ios-machostubs.sh still did not actually include Foundation generation.
   - Evidence:
     Foundation generation check only printed:
       49:# CoreFoundation framework stub.
     and did not show:
       Foundation framework stub
       FOUNDATION_FRAMEWORK_DIR
       _NSClassFromString
       ___CFConstantStringClassReference
   - Decision:
     Do not push until Foundation generation is truly present.

126. Root cause of failed Foundation script insertion:
   - The script-insertion guard used the string:
     "Foundation framework stub."
   - That string already existed elsewhere in repo/docs-related context or generated snippets, causing a false "already present" result.
   - The actual build-ios-machostubs.sh file did not contain the expected Foundation block.
   - Corrected detection strategy:
     Check for:
       FOUNDATION_FRAMEWORK_DIR=
     instead of the broader prose string.
   - This avoided another false positive and made the insertion test more specific.

127. Foundation stub generation added to build-ios-machostubs.sh:
   - File:
     scripts/build-ios-machostubs.sh
   - Added section:
     # Foundation framework stub.
   - Added variable:
     FOUNDATION_FRAMEWORK_DIR="$STUB_ROOT/System/Library/Frameworks/Foundation.framework"
   - Generated assembly source:
     Foundation_stub.s
   - Exported symbols:
     ___CFConstantStringClassReference
     _NSClassFromString
   - Built with:
     arm-apple-darwin-as -arch armv7
     arm-apple-darwin-ld -arch armv7 -dylib
       -install_name /System/Library/Frameworks/Foundation.framework/Foundation
   - Added Headers symlink if THEOS and SDK headers exist:
     Foundation.framework/Headers
     ->
     $THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/Foundation.framework/Headers
   - Added verification:
     file "$FOUNDATION_FRAMEWORK_DIR/Foundation"
     arm-apple-darwin-nm -g ... | grep -E 'NSClassFromString|CFConstantStringClassReference'

128. Phase 4 re-run passed cleanup criteria:
   - scripts/__pycache__ was removed.
   - .gitignore included:
     __pycache__/
     *.pyc
   - Stale validation wording scan returned no hits.
   - Script syntax checks completed without visible failures:
     bash -n scripts/build-toolchain.sh
     bash -n scripts/build-ios-machostubs.sh
     bash -n scripts/setup-theos-toolchain-links.sh
     bash -n scripts/verify-toolchain.sh
     bash -n scripts/install-deps-ubuntu-24.04.sh
   - Foundation generation check now showed:
     # Foundation framework stub.
     ___CFConstantStringClassReference
     _NSClassFromString
     arm-apple-darwin-nm ... NSClassFromString|CFConstantStringClassReference
   - Nullability wrapper check still showed expected suppressions in both clang and clang++ wrappers:
     -Wno-nullability-inferred-on-nested-type
     -Wno-nullability-completeness-on-arrays
     -Wno-nullability-completeness
   - Early machostubs paths remained present:
     -F"$HOME/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks"
     -L"$HOME/ios-sdk-machostubs/iPhoneOS9.3/usr/lib"

129. Repo cleanup changes staged for push:
   - .gitignore updated for Python cache artifacts.
   - PATCHES.md rewritten to describe current live patching:
     scripts/apply-linux-wsl-patches.py
   - README.md top status refreshed to current ladder:
     toolchain build/install/verify
     Theos wrapper setup
     no-op .deb
     ObjC runtime symbol package
     CoreFoundation package
     Foundation package
   - docs/MACHO_STUBS.md rewritten to document:
     .tbd incompatibility
     real Mach-O stubs
     validated libobjc/libSystem/CoreFoundation/Foundation stubs
     framework header symlink rule
     nullability suppressions
   - docs/FOUNDATION_STUBS.md updated/normalized.
   - docs/CURRENT_STATUS.md added.
   - patches/*.patch moved to:
     docs/obsolete-patch-sketches/
   - patches/README.md added to explain that patches/ is intentionally inactive.
   - docs/obsolete-patch-sketches/README.md added to explain historical status of old patch sketches.
   - scripts/build-ios-machostubs.sh updated with Foundation stub generation.

130. Repo cleanup push approved:
   - After final Phase 4 review, push was approved.
   - Recommended commit:
     git commit -m "Clean up repo status and framework stub docs"
   - Rationale:
     The repo now better matches actual project state and avoids leading future readers into invalid patch-file use.
   - Important:
     This cleanup commit is documentation/repro hardening.
     It does not validate new device behavior and does not change the iPhone risk model.

131. Things to avoid in future repo/project work:
   - Do not treat LogDoc truth and repo truth as interchangeable.
     The repo must be periodically synchronized after major breakthroughs.
   - Do not leave invalid/obsolete patch files in a live build path.
     Historical artifacts should be moved under docs/obsolete-* with explicit warnings.
   - Do not use broad string guards like "Foundation framework stub." for script insertion when the same phrase may appear in docs.
     Prefer specific code anchors such as variable names or function names:
       FOUNDATION_FRAMEWORK_DIR=
   - Do not ignore pycache artifacts after running python3 -m py_compile.
     Ensure .gitignore covers:
       __pycache__/
       *.pyc
   - Do not push after a failed heredoc or partially pasted shell/Python block without a status/diff/syntax review.
   - Do not assume a grep check is sufficient if it can match nearby/older sections.
     Check for all expected anchors:
       section header
       variable name
       symbol names
       build commands
   - Do not start device-side work immediately after repo cleanup.
     Resume host-side validation first.
   - Do not conflate:
       host linker stubs
     with:
       runtime implementations.
     The device provides real frameworks; generated stubs are only linker aids.
   - Do not install on the iPhone until a deliberate harmless install/uninstall plan exists.
   - Do not allow old "unvalidated" wording to remain near the top of README once later sections document validated milestones.

132. Current repo state after cleanup pass:
   - Reproducible toolchain automation:
     WORKING and documented.
   - Live source patching:
     scripts/apply-linux-wsl-patches.py.
   - Obsolete patch sketches:
     quarantined as docs-only historical artifacts.
   - Theos wrapper setup:
     documented and includes:
       compiler wrapper behavior
       module flag stripping
       nullability suppressions
       early Mach-O stub paths
       ldid wrapper behavior
   - Mach-O stub generation:
     scripts/build-ios-machostubs.sh now covers:
       libobjc
       libSystem
       CoreFoundation
       Foundation
   - Framework docs:
     updated to explain Headers symlink requirement.
   - Current status doc:
     added for future project-state lookup.

133. Current technical ladder after repo cleanup:
   - Toolchain reproducible build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE enough for current host tests
   - No-op .deb:
     COMPLETE
   - Objective-C runtime symbol .deb:
     COMPLETE
   - CoreFoundation .deb:
     COMPLETE
   - Foundation .deb:
     COMPLETE
   - Logos hook package after latest wrappers/stubs:
     NOT REVALIDATED
   - MobileSubstrate/CydiaSubstrate stubs:
     NOT SOLVED
   - Harmless device install/uninstall:
     NOT ATTEMPTED
   - FakeGPS implementation:
     NOT STARTED

134. Recommended next technical branch:
   - Return to host-side toolchain/tweak validation.
   - Next preferred milestone:
     Revalidate Logos with the improved wrappers and Foundation/CoreFoundation stubs.
   - Reason:
     The earlier Logos issue came from __unused in generated constructor context and happened before the current wrapper/stub maturity.
     Before solving Substrate or real FakeGPS logic, confirm whether a minimal Logos-generated tweak can compile/link/package now.
   - If Logos still fails:
     Patch/define __unused or adjust compile flags minimally.
   - If Logos passes:
     Move to MobileSubstrate/CydiaSubstrate link test.
   - Still avoid device install.

Breakpoint note:
   - This is a useful repo-maintenance checkpoint.
   - The project now has a cleaner split between:
     historical archaeology
     live reproducible build path
     current validated host milestones
     unresolved future risk.
   - Next work should resume on host-side Logos/Substrate validation, not device install or GPS spoof logic.


135. Began Logos revalidation branch after repo cleanup:
   - Goal:
     Revalidate a real Logos-generated tweak after the wrapper/stub maturity reached:
       no-op package
       ObjC runtime package
       CoreFoundation package
       Foundation package
   - New clean host-side test project:
     ~/LogosHookTest
   - Purpose:
     Answer one narrow question:
       Can a minimal Logos-generated MobileSubstrate tweak compile, link, sign, stage, and package?
   - Test hook:
     %hook SpringBoard
     - (void)applicationDidFinishLaunching:(id)application {
         %orig;
     }
     %end
   - Target:
     ARCHS = armv7
     TARGET = iphone:clang:9.3:6.1
   - Device install:
     NOT ATTEMPTED.

136. First LogosHookTest build result:
   - Logos preprocessing succeeded:
     /home/bitcrusher32/theos/bin/logos.pl generated:
       .theos/obj/debug/armv7/Tweak.xm.mm
   - Objective-C++ compilation succeeded:
     .theos/obj/debug/armv7/Tweak.xm.<hash>.o was emitted.
   - Link reached CydiaSubstrate discovery and failed:
     ld: framework not found CydiaSubstrate for architecture armv7
   - Interpretation:
     Logos code generation and compile path were working.
     The new blocker was expected:
       a real Mach-O CydiaSubstrate.framework stub was not yet available in the early framework search path.

137. Created first CydiaSubstrate Mach-O framework stub:
   - Stub path:
     ~/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
   - Initial exported symbol:
     _MSHookMessageEx
   - Source:
     CydiaSubstrate_stub.s
   - Built using:
     arm-apple-darwin-as -arch armv7
     arm-apple-darwin-ld -arch armv7 -dylib
       -install_name /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
   - Purpose:
     Give old ld64 a real Mach-O framework binary instead of Theos' .tbd CydiaSubstrate stub.

138. Added Library/Frameworks machostub path to wrappers:
   - Existing wrappers already searched:
     ~/ios-sdk-machostubs/iPhoneOS9.3/System/Library/Frameworks
   - CydiaSubstrate lives under:
     /Library/Frameworks/CydiaSubstrate.framework
   - Therefore wrappers were updated to also search:
     -F"$HOME/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks"
   - This is a distinct path from System/Library/Frameworks and must be handled explicitly.
   - Result:
     The compiler began finding the stub CydiaSubstrate.framework.

139. Header lookup issue found for CydiaSubstrate:
   - After adding early Library/Frameworks machostub path, compile failed before link:
     /home/bitcrusher32/theos/vendor/include/substrate.h:1:10:
       fatal error: 'CydiaSubstrate/CydiaSubstrate.h' file not found
   - Clang note:
     did not find header 'CydiaSubstrate.h' in framework 'CydiaSubstrate'
     loaded from:
       /home/bitcrusher32/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks
   - Interpretation:
     Same class of issue as Foundation/CoreFoundation:
       once the stub framework is found early, it also needs a valid Headers directory.
   - Important:
     Do not handwrite a fake CydiaSubstrate.h if a real Theos header exists.

140. Found real Theos CydiaSubstrate headers:
   - Header search showed:
     /home/bitcrusher32/theos/vendor/include/CydiaSubstrate.h
     /home/bitcrusher32/theos/vendor/include/substrate.h
     /home/bitcrusher32/theos/vendor/lib/CydiaSubstrate.framework/Headers/CydiaSubstrate.h
     /home/bitcrusher32/theos/vendor/lib/CydiaSubstrate.framework/CydiaSubstrate.tbd
     plus rootless/orion variants.
   - Decision:
     Use the real Theos vendor framework header, not a handwritten minimal header.
   - Fix:
     Add symlink:
       ~/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks/CydiaSubstrate.framework/Headers
       ->
       $THEOS/vendor/lib/CydiaSubstrate.framework/Headers

141. LogosHookTest package milestone:
   - After:
     - CydiaSubstrate Mach-O framework stub
     - early -F path for Library/Frameworks machostubs
     - Headers symlink to Theos' real CydiaSubstrate framework headers
     LogosHookTest completed:
       - Logos preprocessing
       - Objective-C++ compilation
       - Darwin linking
       - ldid signing
       - staging into /Library/MobileSubstrate/DynamicLibraries
       - .deb package creation
   - Confirmed package artifact:
     ./packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - Confirmed staged dylib:
     ./.theos/_/Library/MobileSubstrate/DynamicLibraries/LogosHookTest.dylib
   - Confirmed build log reached:
     dm.pl: building package `com.bitcrusher32.logoshooktest:iphoneos-arm'
   - Confirmed object/dylib artifacts:
     ./.theos/obj/debug/armv7/Tweak.xm.<hash>.o
     ./.theos/obj/debug/armv7/LogosHookTest.dylib
     ./.theos/obj/debug/LogosHookTest.dylib
   - Interpretation:
     This is the first validated host-side Logos/MobileSubstrate package baseline.

142. Updated validated ladder after LogosHookTest:
   - Toolchain reproducible build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE enough for current host tests
   - No-op .deb:
     COMPLETE
   - Objective-C runtime symbol .deb:
     COMPLETE
   - CoreFoundation .deb:
     COMPLETE
   - Foundation .deb:
     COMPLETE
   - Logos/MobileSubstrate minimal hook .deb:
     COMPLETE host-side
   - Harmless device install/uninstall:
     NOT ATTEMPTED
   - FakeGPS implementation:
     NOT STARTED

143. Meaning of LogosHookTest success:
   - The previous early Logos failure around generated code was no longer the blocker.
   - With the current wrappers and stubs, the host-side Logos flow can now produce a package.
   - The CydiaSubstrate framework stub/header strategy follows the same general rule:
     real Mach-O framework binary
     plus real Headers symlink
     plus early -F path
   - This validates the toolchain and Theos packaging path far beyond a no-op source.
   - However, it still does not prove device runtime behavior.

144. Remaining risk/caveats after Logos milestone:
   - The generated CydiaSubstrate.framework/CydiaSubstrate is a host-side linker stub only.
   - It is not a runtime implementation.
   - The target iPhone's installed MobileSubstrate/CydiaSubstrate environment must provide the actual runtime behavior.
   - The stub install_name must remain compatible with expected on-device framework/library layout.
   - No device install has occurred.
   - Do not jump directly to real GPS spoofing.
   - Next safe branch should be a deliberate harmless install/uninstall plan, or an additional host-side validation of package metadata/load commands.

145. Repo sync required after Logos milestone:
   - scripts/build-ios-machostubs.sh should be updated to generate:
     Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
     with at least:
       _MSHookMessageEx
     and probably _MSHookFunction as a common future symbol.
   - scripts/build-ios-machostubs.sh should add:
     CydiaSubstrate.framework/Headers
     ->
     $THEOS/vendor/lib/CydiaSubstrate.framework/Headers
   - scripts/setup-theos-toolchain-links.sh should add early:
     -F"$HOME/ios-sdk-machostubs/iPhoneOS9.3/Library/Frameworks"
     to both clang and clang++ wrapper exec lines.
   - docs/MACHO_STUBS.md should add CydiaSubstrate as a validated stub.
   - docs/CURRENT_STATUS.md and README.md should move Logos hook package from NOT validated to validated host-side.
   - Add a dedicated doc:
     docs/CYDIASUBSTRATE_STUBS.md
   - Optionally add:
     examples/logos-hook-test/
     later, but avoid bloating the repo before deciding how examples should be structured.

146. Suggested next technical sequence:
   - First:
     Commit/push the CydiaSubstrate/Logos host-side baseline into the reproducibility repo.
   - Second:
     Run package artifact inspections:
       file packages/*.deb
       file .theos/obj/debug/armv7/LogosHookTest.dylib
       arm-apple-darwin-otool -L .theos/obj/debug/armv7/LogosHookTest.dylib
       arm-apple-darwin-nm -u .theos/obj/debug/armv7/LogosHookTest.dylib
   - Third:
     Design a harmless device install/uninstall protocol before actually installing anything.
   - Fourth:
     Only after install/uninstall safety is clear, consider a tiny no-op/logging hook on device.
   - Fifth:
     Start FakeGPS MVP only after the device safety workflow is validated.

147. Things to avoid after Logos success:
   - Do not treat "package builds" as "safe to install."
   - Do not assume the host linker stub's install_name/runtime path is perfect until otool/load-command inspection is reviewed.
   - Do not install onto the iPhone before confirming:
       package contents
       control metadata
       DynamicLibraries path
       uninstall command
       SSH recovery path
       Safe Mode/reboot expectations
   - Do not write FakeGPS logic before a harmless package install/uninstall path is tested.
   - Do not replace real Theos CydiaSubstrate headers with a handmade minimal header unless absolutely necessary.
   - Do not forget that CydiaSubstrate lives under Library/Frameworks, not System/Library/Frameworks.
   - Do not push repo docs claiming runtime validation; this is host-side validation only.

Breakpoint note:
   - This is a major breakpoint.
   - The project has now crossed from Foundation host packaging to actual Logos/MobileSubstrate host packaging.
   - The next risk boundary is no longer "can the host build a tweak?"
     It is:
       "can we safely inspect, install, unload, and uninstall a harmless tweak on the preserved iPhone without risking device state?"


148. Versioning/naming schema update:
   - The LogDoc naming scheme is changing for major scope changes.
   - Previous versions used simple whole-number suffixes:
     v18, v19, v20, v21
   - New major-scope naming uses a prefixed digit count / semantic split:
     V1.21
   - Meaning:
     V1 = major project scope:
       Legacy iOS ARMv7 toolchain + Theos host-side preservation/reproducibility.
     .21 = timeline continuity from the previous v21 checkpoint.
   - Rationale:
     The project is now entering a broader preservation/appliance phase rather than only iterative compile-error debugging.
   - Future examples:
     V1.22 = next checkpoint within this toolchain/appliance scope.
     V2.00 = first major scope change, such as real device install/uninstall validation or FakeGPS implementation becoming the primary project branch.

149. New preservation objective after Logos milestone:
   - User requested a shift from feature/debug work to fully preserving the toolchain environment.
   - Goal:
     Flesh out the toolchain until it is fully reproducible and create a container-adjacent preserved environment.
   - Preference:
     Not necessarily Docker.
     Prefer something cleanly runnable under WSL/current Ubuntu environment.
   - Recommended preservation model:
     Use two layers:
       1. Git repo as the reproducible recipe.
       2. WSL export/import as the preserved known-good appliance.
   - Reason:
     The project is already WSL-native and depends on a fragile blend of:
       patched legacy toolchain
       modern Ubuntu packages
       Theos
       SDKs
       wrapper scripts
       generated Mach-O stubs
     A WSL distro export preserves the exact known-good Linux userspace without introducing Docker-specific differences.

150. Current validated host ladder before appliance work:
   - Reproducible toolchain build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE enough for current host tests
   - Mach-O stub generation:
     libobjc, libSystem, CoreFoundation, Foundation, CydiaSubstrate
   - No-op Theos .deb:
     COMPLETE
   - Objective-C runtime symbol .deb:
     COMPLETE
   - CoreFoundation symbol .deb:
     COMPLETE
   - Foundation symbol .deb:
     COMPLETE
   - Logos/MobileSubstrate minimal hook .deb:
     COMPLETE host-side
   - Harmless device install/uninstall:
     NOT ATTEMPTED
   - FakeGPS implementation:
     NOT STARTED
   - Device runtime validation:
     NOT ATTEMPTED

151. New near-term milestone: repo-hosted examples:
   - The validated test projects currently live in home-directory throwaway folders:
     ~/NoOpTweak
     ~/ObjCRuntimeTest
     ~/CoreFoundationTest
     ~/FoundationTest
     ~/LogosHookTest
   - For real reproducibility, these should be copied into the repository as examples:
     examples/noop-tweak/
     examples/objc-runtime-test/
     examples/corefoundation-test/
     examples/foundation-test/
     examples/logos-hook-test/
   - Purpose:
     Make the repo able to validate the entire host-side build ladder without relying on memory or ad-hoc home-directory state.
   - Each example should be minimal, harmless, and host-side only.
   - No example should include real GPS spoofing logic yet.

152. New near-term milestone: full host validation script:
   - Add:
     scripts/validate-host-pipeline.sh
   - Purpose:
     Run the complete reproducibility and host-side package proof chain.
   - Expected high-level flow:
     1. Verify installed toolchain commands.
     2. Run ARMv7 Mach-O smoke tests.
     3. Set up Theos toolchain wrapper links.
     4. Generate Mach-O SDK stubs.
     5. Build each repo-hosted example:
        - noop-tweak
        - objc-runtime-test
        - corefoundation-test
        - foundation-test
        - logos-hook-test
     6. Confirm .deb artifacts are produced for each package example.
   - Important:
     This validation script should not install anything on the iPhone.
     It should prove host-side reproducibility only.

153. New near-term milestone: docs for appliance preservation:
   - Add:
     docs/WSL_APPLIANCE_EXPORT.md
   - Purpose:
     Document how to preserve the known-good environment using WSL export/import.
   - Recommended PowerShell export flow:
     wsl --list --verbose
     wsl --shutdown
     mkdir C:\WSL-Backups
     wsl --export Ubuntu C:\WSL-Backups\legacy-ios-toolchain-wsl-v1.tar
   - Recommended restore/import flow:
     mkdir C:\WSL\legacy-ios-toolchain-wsl-v1
     wsl --import LegacyIOSToolchain C:\WSL\legacy-ios-toolchain-wsl-v1 C:\WSL-Backups\legacy-ios-toolchain-wsl-v1.tar
     wsl -d LegacyIOSToolchain
   - Note:
     Actual distro name may differ from "Ubuntu"; user should confirm with:
       wsl --list --verbose

154. New near-term milestone: appliance manifest:
   - Add:
     docs/APPLIANCE_MANIFEST.md
   - Purpose:
     Record the exact known-good environment details needed to recreate or audit the preserved appliance.
   - Manifest should include:
     - WSL distro name
     - Ubuntu version
     - repo path and commit hash
     - Theos path
     - SDK versions present
     - installed toolchain binary paths
     - arm-apple-darwin-ld version
     - clang version used by wrappers
     - wrapper script paths
     - machostub root path
     - generated Mach-O stubs
     - validated example packages
     - WSL export filename
     - SHA256 checksum of exported tar
   - PowerShell checksum:
     Get-FileHash C:\WSL-Backups\legacy-ios-toolchain-wsl-v1.tar -Algorithm SHA256
   - WSL checksum:
     sha256sum /mnt/c/WSL-Backups/legacy-ios-toolchain-wsl-v1.tar

155. Recommended appliance model:
   - Do not preserve only the current daily/messy WSL instance as the final artifact.
   - Instead:
     1. Keep the current WSL as the working archaeology lab.
     2. Create or import a clean appliance-style WSL distro later.
     3. Clone the repo into it.
     4. Run the full host validation script.
     5. Export that clean validated distro.
   - This yields:
     Git repo = reproducible recipe.
     WSL export = preserved working appliance.
   - This is more aligned with the project than Docker because:
     - WSL is already the active target environment.
     - Docker may introduce new filesystem, init, path, permission, or nested-toolchain differences.
     - The goal is preservation and reproducibility, not cloud deployment.

156. Proposed repo additions for V1 appliance work:
   - examples/noop-tweak/
   - examples/objc-runtime-test/
   - examples/corefoundation-test/
   - examples/foundation-test/
   - examples/logos-hook-test/
   - scripts/validate-host-pipeline.sh
   - docs/WSL_APPLIANCE_EXPORT.md
   - docs/APPLIANCE_MANIFEST.md
   - Optional later:
     scripts/create-example-projects.sh
     scripts/inspect-package-artifacts.sh
     docs/DEVICE_INSTALL_SAFETY_PLAN.md

157. Order of operations for the next work branch:
   - Step 1:
     Add repo-hosted examples.
   - Step 2:
     Add validate-host-pipeline.sh.
   - Step 3:
     Run the script on the current WSL.
   - Step 4:
     Fix any path assumptions discovered by validation.
   - Step 5:
     Commit/push the self-verifying repo.
   - Step 6:
     Create appliance export docs and manifest template.
   - Step 7:
     Build a clean appliance WSL distro and run validation inside it.
   - Step 8:
     Export the validated appliance tar and checksum it.
   - Step 9:
     Only after that, return to package inspection and harmless install/uninstall planning.

158. What not to do during appliance phase:
   - Do not start FakeGPS logic.
   - Do not install anything on the iPhone.
   - Do not assume the current home-directory test projects are enough for reproducibility.
   - Do not rely on undocumented manual wrapper edits.
   - Do not preserve an appliance without also recording the repo commit hash and checksums.
   - Do not conflate:
       host-side package validation
     with:
       device runtime validation.
   - Do not overfit the appliance to the current username if scripts can use $HOME and $THEOS.
   - Do not make Docker the first preservation target unless WSL export fails to satisfy the requirement.

159. Current project meaning after V1.21:
   - The project has evolved from:
     "recover this broken legacy toolchain"
     into:
     "preserve a reproducible legacy iOS ARMv7 tweak build appliance."
   - The next success condition is not a new compile hack.
   - The next success condition is:
     A cloneable repo plus a clean preserved WSL environment that can rebuild and validate all current host-side milestones.

Breakpoint note:
   - V1.21 marks the transition into the preservation/appliance phase.
   - The iPhone remains untouched.
   - The next branch should start with repo examples and host validation scripting.


160. Repository self-verification branch completed:
   - After V1.21, the project shifted from one-off host validation to repo-contained reproducibility.
   - Decision:
     Keep the examples and validation tooling in the same repository:
       git.bitcrusher32.win/bitcrusher32/theros-monumental-wsl-toolkit
     rather than creating a second repo.
   - Rationale:
     The examples and validation script are not a separate product.
     They are the self-test layer for the same legacy iOS ARMv7 toolchain appliance.
   - Result:
     The repository now acts as:
       - reproducible recipe
       - test harness
       - preservation documentation
       - host-side validation suite

161. Repo-hosted examples added:
   - Added/normalized examples under:
     examples/noop-tweak/
     examples/objc-runtime-test/
     examples/corefoundation-test/
     examples/foundation-test/
     examples/logos-hook-test/
   - Source projects were copied from known-good home-directory test projects while excluding generated outputs:
     .theos/
     packages/
   - Purpose:
     Avoid relying on ephemeral home-directory throwaway projects.
     Future clone/import environments can validate the exact same milestone ladder from the repository itself.
   - Important:
     Generated .theos/ and packages/ directories are ignored and should not be committed.

162. Host validation pipeline added:
   - New script:
     scripts/validate-host-pipeline.sh
   - Pipeline validates:
     1. scripts/verify-toolchain.sh
     2. scripts/setup-theos-toolchain-links.sh
     3. scripts/build-ios-machostubs.sh
     4. examples/noop-tweak package
     5. examples/objc-runtime-test package
     6. examples/corefoundation-test package
     7. examples/foundation-test package
     8. examples/logos-hook-test package
   - This gives the repo a single command to prove the current host-side build/package ladder.
   - Validation remains host-side only.
   - No device install is performed by this script.

163. First repo-contained validation succeeded:
   - Command:
     ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-1.log
   - Result:
     Host pipeline validation complete.
   - Generated packages:
     examples/noop-tweak/packages/com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb
     examples/objc-runtime-test/packages/com.bitcrusher32.objcruntimetest_0.0.1-1+debug_iphoneos-arm.deb
     examples/corefoundation-test/packages/com.bitcrusher32.corefoundationtest_0.0.1-1+debug_iphoneos-arm.deb
     examples/foundation-test/packages/com.bitcrusher32.foundationtest_0.0.1-1+debug_iphoneos-arm.deb
     examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - This confirmed that repo-hosted examples can reproduce the full current host-side milestone ladder.

164. Generated outputs cleanup and ignore policy:
   - After validation, generated build outputs were removed before commit:
     examples/*/.theos/
     examples/*/packages/
     validate-host-pipeline-*.log
   - .gitignore was updated/used to prevent:
     .theos/
     packages/
     examples/*/.theos/
     examples/*/packages/
     logs/local/
     validate-host-pipeline-*.log
   - Rationale:
     The repo should store source, scripts, and documentation, not generated packages or build intermediates.
   - Packages are reproducible artifacts, not canonical source.

165. WSL appliance docs added:
   - Added:
     docs/WSL_APPLIANCE_EXPORT.md
     docs/APPLIANCE_MANIFEST.md
   - Initial paste attempt was rejected because formatting had degraded:
     missing code fences, headings lost Markdown markers, and commands collapsed into prose.
   - Safer second version used plain indented command blocks instead of nested fenced code blocks.
   - Result:
     Documentation rendered cleanly and was committed.
   - docs/WSL_APPLIANCE_EXPORT.md now explains:
     - why WSL export is preferred before Docker
     - how to validate before export
     - how to export from PowerShell
     - how to import/restore-test
     - what the appliance does and does not validate
   - docs/APPLIANCE_MANIFEST.md records:
     - environment details
     - repo commit details
     - toolchain paths
     - Theos paths
     - wrapper behavior
     - Mach-O stubs
     - validation outputs
     - export metadata
     - restore-test metadata
     - safety boundary

166. Manifest snapshot helper added:
   - Added:
     scripts/update-appliance-manifest.sh
   - Purpose:
     Auto-fill environment snapshot data instead of manually copy/pasting many commands.
   - Captures:
     - timestamp
     - git branch/commit/status
     - git remote
     - Ubuntu release info
     - kernel/user/home
     - installed toolchain binary paths
     - arm-apple-darwin-ld version output
     - Theos path and SDK list
     - Theos wrapper directory listing
     - Mach-O stub tree
   - Leaves export and restore-test fields for explicit post-export fill.
   - This reduces manual transcription mistakes and makes future appliance snapshots repeatable.

167. Host validation before export succeeded:
   - Ran:
     ./scripts/update-appliance-manifest.sh
     ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-appliance.log
   - Validation generated the expected five example .deb packages.
   - Manifest was updated to:
     Status: HOST VALIDATION PASSED / READY FOR WSL EXPORT
     validation_result=PASS_HOST_PIPELINE
   - Generated validation logs and example build outputs were cleaned before commit/export.
   - This established a clean pre-export state.

168. WSL appliance export completed:
   - Windows PowerShell source distro listing:
       Ubuntu            Running  2
       docker-desktop    Stopped  2
   - Export source distro:
       Ubuntu
   - WSL version:
       2
   - Export path:
       C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
   - Export reported:
       Export in progress, this may take a few minutes. (5419 MB)
       The operation completed successfully.
   - File size:
       5,689,487,360 bytes
   - SHA256:
       781764A4DFA80340E8FD18C162A10B23658A4AB807DEF9301B84C4EC8DC123D8
   - Manifest was updated with:
       source_distro=Ubuntu
       export_path=C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
       export_size=5689487360 bytes
       sha256=781764A4DFA80340E8FD18C162A10B23658A4AB807DEF9301B84C4EC8DC123D8

169. WSL export privacy boundary documented:
   - Important conclusion:
     The WSL export tar must be treated as private.
   - Reason:
     A WSL export is effectively a full Linux filesystem image.
   - It may include:
     shell history
     SSH keys/config
     Git credentials or credential caches
     tokens/auth files
     private repos/files
     downloaded SDKs or license-restricted files
     device notes/IPs/password notes
     usernames and local paths
   - Rule:
     Do not commit the .tar to Git.
     Do not publish it publicly.
     Store it on local encrypted/private storage.
   - Manifest now includes an explicit export privacy warning.

170. Restore-test import completed:
   - PowerShell commands created:
       C:\WSL\LegacyIOSToolchain-V1.21
   - Imported:
       wsl --import LegacyIOSToolchain-V1.21 C:\WSL\LegacyIOSToolchain-V1.21 C:\WSL-Backups\legacy-ios-toolchain-wsl-V1.21.tar
   - Import result:
       The operation completed successfully.
   - WSL list after import:
       Ubuntu                      Running  2
       LegacyIOSToolchain-V1.21    Stopped  2
       docker-desktop              Stopped  2
   - Launched restored distro:
       wsl -d LegacyIOSToolchain-V1.21
   - Restored shell entered as:
       bitcrusher32@▓▓:/mnt/c/Users/▓▓$

171. Restore-test validation succeeded:
   - Inside restored distro, ran:
       cd ~/legacy-ios-toolchain-wsl
       git status --short
       ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-restored.log
   - Validation again generated Mach-O stubs and built all repo-hosted examples.
   - Output showed:
     - toolchain smoke verification passed
     - Theos wrappers installed
     - Mach-O stubs generated:
       libobjc
       libSystem
       CoreFoundation
       Foundation
       CydiaSubstrate
     - no-op package built
     - ObjC runtime package built
     - CoreFoundation package built
     - Foundation package built
     - Logos hook package built
   - Restore validation result recorded in manifest:
       restore_validation_result=PASS_HOST_PIPELINE_RESTORED_WSL
   - This proves the exported WSL appliance can be imported and still reproduce the host-side build/package ladder.

172. Restore-test Git push conflict and resolution:
   - While committing restore validation from the restored distro, push initially failed:
       rejected: fetch first
   - Cause:
     The restored WSL repo snapshot was behind the remote because it was created from an earlier exported filesystem state.
   - Local commit:
       Record WSL appliance restore validation
   - Safe resolution:
     - create backup branch
     - git fetch origin
     - inspect local-only and remote-only commits
     - git pull --rebase origin main
     - git push
   - Force push was avoided.
   - Final result:
     manifest restore-validation commit was successfully integrated and pushed.

173. Appliance preservation milestone achieved:
   - The project now has:
     - Git repo as reproducible recipe
     - repo-hosted examples
     - full host validation script
     - appliance export docs
     - manifest snapshot helper
     - WSL export tar
     - SHA256 checksum
     - restored WSL import test
     - restored host pipeline validation
   - This is the first full container-adjacent preservation checkpoint.
   - The exported appliance is private and should be stored securely.
   - The repo remains public/shareable only if SDK/legal/private material is not committed.
   - The exported tar itself is not public/shareable.

174. Updated current validated ladder after appliance milestone:
   - Toolchain reproducible build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE
   - Mach-O stub generation:
     COMPLETE for current baseline:
       libobjc
       libSystem
       CoreFoundation
       Foundation
       CydiaSubstrate
   - Repo-hosted examples:
     COMPLETE
   - Full host validation pipeline:
     COMPLETE
   - WSL export:
     COMPLETE
   - WSL restore/import test:
     COMPLETE
   - Restored host validation:
     COMPLETE
   - Harmless device install/uninstall:
     NOT ATTEMPTED
   - Device runtime validation:
     NOT ATTEMPTED
   - FakeGPS implementation:
     NOT STARTED

175. Current project meaning after V1.22:
   - The project has crossed from:
       "working local archaeology"
     into:
       "preserved WSL build appliance with reproducible host-side validation."
   - The next risk boundary is no longer host build preservation.
   - The next risk boundary is device safety.
   - The iPhone remains untouched by the new packages.
   - No install, uninstall, SpringBoard hook runtime, or GPS spoofing behavior has been validated on device.

176. Recommended next branch after V1.22:
   - Do not start FakeGPS implementation yet.
   - Next step should be a device-safe install/uninstall protocol document:
       docs/DEVICE_INSTALL_SAFETY_PLAN.md
   - It should cover:
       - iPhone current backup state
       - SSH connectivity confirmation
       - root password change consideration
       - dpkg install command
       - dpkg remove/purge command
       - where tweaks install:
         /Library/MobileSubstrate/DynamicLibraries/
       - how to disable a bad tweak over SSH
       - Safe Mode expectations
       - reboot/respring commands
       - package contents inspection
       - test package selection
       - exact rollback steps
   - Then perform package inspection on the no-op or LogosHookTest .deb before installation.
   - Only after a harmless install/uninstall succeeds should FakeGPS logic begin.

177. Things to avoid after appliance milestone:
   - Do not publish the WSL export tar.
   - Do not commit generated packages unless deliberately creating a release artifact.
   - Do not install on the iPhone without a reviewed safety plan.
   - Do not treat host-side Logos package success as runtime success.
   - Do not skip package inspection before install.
   - Do not start with GPS hooks; start with no-op or logging-only harmless package.
   - Do not assume the restored distro's Git state is current before pushing; fetch/rebase first.
   - Do not rely on the appliance alone; keep the repo recipe validated and current.

Breakpoint note:
   - V1.22 is a major preservation checkpoint.
   - The repo and WSL appliance now provide two separate recovery routes:
     1. reproducible scripts/examples/docs through Git
     2. exact known-good environment through private WSL export/import
   - Next work should move from host preservation to device safety planning, still without touching GPS logic.


178. Post-V1.22 repo cleanup session started:
   - User requested another cleanup pass before continuing into device safety.
   - Reason:
     The project scope had changed once into preservation/appliance work, and that scope was now effectively complete.
   - Inputs:
     - current V1.22 LogDoc
     - current repository zip snapshot
     - terminal outputs from cleanup Phase 4 and Phase 5
   - Goal:
     Make the Git repository front door match the completed V1 host-side/appliance reality before opening the next device-safety branch.
   - Decision:
     Cleanup should be performed in the original Ubuntu WSL environment, not the restored appliance distro.
   - Rationale:
     Original Ubuntu remains the active development/workbench environment.
     LegacyIOSToolchain-V1.21 remains a frozen verification artifact / fallback image.

179. V1.22 cleanup objective:
   - Update repository language from older "Foundation milestone / not solved" wording to current V1 appliance status.
   - Make README.md useful as a front door:
     - what is validated
     - what is not validated
     - how to build/verify
     - how to set up Theos
     - how to generate Mach-O stubs
     - how to run full host validation
     - where appliance docs live
     - where device-safety planning begins
   - Remove or quarantine historical clutter from active example directories.
   - Add cleanup automation so generated artifacts can be removed consistently.
   - Preserve historical notes without letting them pollute active validation paths.
   - Re-run host validation after cleanup to prove nothing broke.

180. Phase 0 preflight planned:
   - Preflight checks included:
     git status --short
     repository file listing
     generated/private artifact scan
     stale wording scan
     script syntax checks
   - Stale wording scan looked for older phrases such as:
     real Objective-C/Foundation linking is not solved
     temporary .tbd overlay hack
     Validated so far
     Foundation milestone
     V1.21
   - Important interpretation:
     V1.21 hits are acceptable in appliance export docs/manifests when they refer to the actual exported tar name:
       legacy-ios-toolchain-wsl-V1.21.tar

181. Phase 1 script cleanup added:
   - Added:
     scripts/clean-generated-artifacts.sh
   - Purpose:
     Remove generated Theos/example artifacts and local logs without manual repeated find/rm commands.
   - Initial duties:
     - remove examples/*/.theos/
     - remove examples/*/packages/
     - remove validate-host-pipeline-*.log
     - remove common local build logs
     - remove Python __pycache__ directories
   - Later improved to also remove nested example *.log files:
     find examples -maxdepth 2 -type f -name '*.log' -delete
   - Reason:
     Phase 4 found old build logs inside examples/ despite a cleanup pass.

182. Phase 1 validation script hardening:
   - Updated:
     scripts/validate-host-pipeline.sh
   - Previous behavior:
     It printed any found .deb artifacts but did not fail explicitly if none were produced.
   - New behavior:
     For each example, after make package:
       - check that at least one .deb exists under the example's packages directory
       - fail with a clear error if no .deb was produced
   - Benefit:
     The host validation pipeline now fails loudly if packaging silently does not produce an artifact.

183. Phase 1 package inspection fix:
   - Updated:
     scripts/inspect-deb-package.sh
   - Fixed a find precedence issue:
     old:
       find "$TMP/data" -maxdepth 8 -type f -o -type l | sort
     new:
       find "$TMP/data" -maxdepth 8 \( -type f -o -type l \) | sort
   - Reason:
     Without parentheses, find's -o precedence could match symlinks outside the intended maxdepth grouping.
   - This makes package inspection output more predictable before future device install review.

184. Phase 2 obsolete example backup quarantine:
   - Moved historical Makefile snapshots out of active example path:
     examples/noop-tweak/Makefile.pre-ios93-sdk-test
     examples/noop-tweak/Makefile.pre-sdk-usrlib-fix
   - New location:
     docs/obsolete-example-sketches/noop-tweak/
   - Added:
     docs/obsolete-example-sketches/README.md
     docs/obsolete-example-sketches/noop-tweak/README.md
   - Rationale:
     These files are useful archaeology, but they are not active validation inputs.
     Active examples should be minimal and clean.

185. Phase 3 front-door doc rewrite:
   - Rewrote:
     README.md
   - README now presents the repo as:
     Legacy iOS ARMv7 Toolchain Appliance for WSL Ubuntu 24.04
   - README now states V1 host-side preservation scope is complete.
   - README validated list now includes:
     - legacy ARMv7 iOS toolchain build/install/verify
     - fresh reproducible toolchain build
     - Theos wrapper setup
     - Mach-O SDK stub generation
     - no-op tweak .deb
     - Objective-C runtime symbol .deb
     - CoreFoundation symbol .deb
     - Foundation symbol .deb
     - Logos/MobileSubstrate minimal hook .deb
     - repo-hosted full host validation pipeline
     - WSL export/import appliance preservation
     - restored appliance host validation
   - README not-validated list now clearly includes:
     - device install/uninstall
     - device runtime behavior
     - SpringBoard runtime hook behavior on the real iPhone
     - FakeGPS logic
     - CoreLocation/locationd spoofing
     - preferences/UI
   - README now points to:
     scripts/install-deps-ubuntu-24.04.sh
     scripts/build-toolchain.sh
     scripts/verify-toolchain.sh
     scripts/setup-theos-toolchain-links.sh
     scripts/build-ios-machostubs.sh
     scripts/validate-host-pipeline.sh
     scripts/clean-generated-artifacts.sh
     scripts/inspect-deb-package.sh
     docs/WSL_APPLIANCE_EXPORT.md
     docs/APPLIANCE_MANIFEST.md
     docs/DEVICE_INSTALL_SAFETY_PLAN.md

186. Phase 3 status doc rewrite:
   - Rewrote:
     docs/CURRENT_STATUS.md
   - Current scope now explicitly defined as:
     V1 legacy iOS ARMv7 toolchain + Theos host-side preservation/reproducibility.
   - Complete section now includes:
     - toolchain recovery/build/install/verify
     - automated Linux/WSL source patching
     - Theos wrapper setup
     - Mach-O SDK stub generation
     - all host-side example packages
     - repo-hosted validation
     - WSL export/import
     - restored appliance validation
   - Not-yet-validated section now focuses on device/runtime/FakeGPS work.
   - Added explicit caveat:
     WSL appliance tar is private and should not be published.

187. Phase 3 Mach-O stub doc rewrite:
   - Rewrote:
     docs/MACHO_STUBS.md
   - Clarified:
     modern .tbd SDK stubs are not consumed by recovered legacy ld64.
   - Clarified:
     .tbd symlink/overlay experiments were diagnostic, not the current solution.
   - Documented generated stub root:
     ~/ios-sdk-machostubs/iPhoneOS9.3
   - Documented override:
     IOS_MACHOSTUBS_ROOT=/custom/path ./scripts/build-ios-machostubs.sh
   - Documented validated stubs:
     - libobjc.dylib exporting _objc_getClass
     - libSystem.dylib exporting dyld_stub_binder
     - CoreFoundation.framework/CoreFoundation exporting _CFStringCreateWithCString and _kCFAllocatorDefault
     - Foundation.framework/Foundation exporting _NSClassFromString and ___CFConstantStringClassReference
     - CydiaSubstrate.framework/CydiaSubstrate exporting _MSHookMessageEx and _MSHookFunction
   - Clarified framework-stub rule:
     a real Mach-O framework binary plus valid Headers symlink is required.
   - Clarified current unresolved areas:
     harmless device install/uninstall workflow
     runtime behavior on actual iPhone
     FakeGPS logic

188. Phase 3 V1 scope doc added:
   - Added:
     docs/V1_PRESERVATION_SCOPE.md
   - Purpose:
     Summarize what V1 did and did not include.
   - V1 completed outcomes:
     - recovered/patched legacy toolchain for WSL Ubuntu 24.04
     - automated Linux/WSL patching
     - build/install/verify
     - Theos wrappers
     - Mach-O SDK stubs
     - no-op / ObjC / CoreFoundation / Foundation / Logos package validation
     - repo-hosted examples
     - full host validation script
     - WSL appliance export
     - WSL appliance restore validation
   - V1 non-goals:
     - device install
     - device uninstall
     - runtime SpringBoard hook validation
     - FakeGPS logic
     - CoreLocation/locationd hooks
     - preference bundles/UI

189. Phase 3 obsolete documentation snapshots:
   - Before rewriting major docs, copied historical versions into:
     docs/obsolete-doc-snapshots/
   - Saved snapshots:
     README.pre-v1.22-cleanup.md
     CURRENT_STATUS.pre-v1.22-cleanup.md
     MACHO_STUBS.pre-v1.22-cleanup.md
   - Reason:
     The old wording is no longer suitable for front-door documentation, but remains useful historical context.
   - Stale wording inside obsolete-doc-snapshots is acceptable.
   - Future scans should exclude obsolete-doc-snapshots when checking live docs.

190. Phase 4 sanity pass:
   - Ran:
     /tmp/04-v122-sanity.sh
   - Script performed:
     - generated artifact cleanup
     - git status
     - bash syntax checks for scripts/*.sh
     - Python compile check for apply-linux-wsl-patches.py
     - generated/private artifact scan
     - stale wording scan
     - V1.21 wording check
     - diff stat/preview
   - Initial Phase 4 finding:
     Active generated/private artifact scan still found old .log files under:
       examples/corefoundation-test/
       examples/foundation-test/
       examples/logos-hook-test/
       examples/noop-tweak/
       examples/objc-runtime-test/
       logs/
   - Interpretation:
     The repository still contained old manual/debug logs in active paths.
     This needed cleanup before pushing.

191. Handling Phase 4 stale wording:
   - Stale wording hits appeared in:
     docs/obsolete-doc-snapshots/CURRENT_STATUS.pre-v1.22-cleanup.md
     docs/obsolete-doc-snapshots/README.pre-v1.22-cleanup.md
   - Decision:
     Acceptable because those are deliberately obsolete snapshots.
   - V1.21 hits appeared in:
     docs/WSL_APPLIANCE_EXPORT.md
     docs/APPLIANCE_MANIFEST.md
     scripts/update-appliance-manifest.sh
   - Decision:
     Acceptable because the appliance export was actually named:
       legacy-ios-toolchain-wsl-V1.21.tar
     and the restore distro was named:
       LegacyIOSToolchain-V1.21
   - Important:
     Do not over-clean historically accurate export names.

192. Phase 5 host validation after cleanup:
   - Ran:
     ./scripts/validate-host-pipeline.sh 2>&1 | tee validate-host-pipeline-v122-cleanup.log
   - Validation confirmed:
     - toolchain smoke verification passed
     - Theos wrapper setup worked
     - Mach-O SDK stubs generated
     - no-op tweak package built
     - ObjC runtime test package built
     - CoreFoundation test package built
     - Foundation test package built
     - Logos hook package built
   - The updated validation script also confirmed .deb artifacts existed for each example.
   - This demonstrated that the doc/script cleanup did not break the host-side build ladder.
   - After validation, generated outputs were cleaned again.

193. Active artifact scan fixed:
   - Old logs were moved/quarantined under:
     docs/obsolete-build-logs/
   - Added:
     docs/obsolete-build-logs/README.md
   - Updated:
     scripts/clean-generated-artifacts.sh
   - Re-ran active-tree artifact scan while excluding:
     docs/obsolete-build-logs
     docs/obsolete-doc-snapshots
     docs/obsolete-example-sketches
     docs/obsolete-patch-sketches
   - Result:
     active generated/private artifact scan returned no output.
   - This means active repo tree no longer contains:
     .theos/
     packages/
     .deb
     .tar
     .log
     __pycache__
     outside intentionally obsolete documentation areas.

194. Final cleanup status before push:
   - Script syntax checks passed:
     bash -n scripts/*.sh
     python3 -m py_compile scripts/apply-linux-wsl-patches.py
   - Active-tree generated/private artifact scan:
     clean
   - Remaining git status included intended changes:
     - README.md modified
     - docs/CURRENT_STATUS.md modified
     - docs/MACHO_STUBS.md modified
     - examples/noop-tweak historical Makefiles moved to docs/obsolete-example-sketches/
     - scripts/inspect-deb-package.sh modified
     - scripts/validate-host-pipeline.sh modified
     - docs/V1_PRESERVATION_SCOPE.md added
     - docs/obsolete-build-logs/ added
     - docs/obsolete-doc-snapshots/ added
     - docs/obsolete-example-sketches/ README files added
     - scripts/clean-generated-artifacts.sh added
   - Commit approved:
     Clean up repo after V1 appliance milestone
   - Push approved.

195. Current project posture after V1.23 cleanup:
   - V1 host preservation/appliance scope remains complete.
   - Repository front door now matches current reality.
   - Active examples are clean and focused.
   - Historical logs/sketches/docs are quarantined under docs/obsolete-*.
   - Generated artifact cleanup is automated.
   - Host validation remains green after cleanup.
   - The next branch can start from a clean repository state:
     device safety plan and package inspection.
   - iPhone remains untouched.
   - No device install has occurred.
   - No FakeGPS implementation has started.

196. Updated things to avoid after V1.23:
   - Do not let old build logs accumulate in active example directories.
   - Do not let stale "not solved" wording persist in README/current status docs after a milestone is solved.
   - Do not delete historically useful artifacts without moving them into docs/obsolete-* if they may help future archaeology.
   - Do not treat obsolete-doc snapshots as live documentation.
   - Do not run stale scans without excluding docs/obsolete-*.
   - Do not push after validation if generated .theos/, packages/, .deb, .tar, .log, or __pycache__ artifacts remain in active paths.
   - Do not resume device work until safety docs and package inspection are committed.

Breakpoint note:
   - V1.23 is a repo hygiene and continuity checkpoint after the V1 appliance milestone.
   - The active repository is ready for device-safety planning.
   - The next technical work should begin with package inspection and a harmless install/uninstall plan, still without GPS logic.


197. V2 scope transition:
   - User requested a scope change before continuing the grind.
   - Previous project identity:
     FakeGPS / iPhone 4s iOS 6.1.3 project.
   - New active project identity:
     Legacy iOS ARMv7 / iPhone 4s iOS 6.1.3 Toolchain project.
   - Version change:
     V1.23 -> V2.23
   - Meaning:
     V2 = major scope change.
     .23 = timeline continuity from the previous V1.23 checkpoint.
   - The active scope now drops FakeGPS as the primary goal.
   - FakeGPS references before this point are historical context only.

198. New V2 project definition:
   - Active goal:
     build, preserve, validate, and generalize a legacy iOS ARMv7 build environment for WSL/Linux.
   - Current primary validation target:
     iPhone 4s
     iOS 6.1.3
     Build 10B329
     ARMv7
     Cydia / MobileSubstrate
     Theos package workflow
   - Core V2 objectives:
     - keep the toolchain reproducible from Git
     - keep Theos wrapper setup reproducible
     - keep Mach-O stub generation reproducible
     - keep host validation green
     - keep WSL appliance preservation documented
     - validate harmless device runtime behavior
     - build a path toward other lost/common legacy iOS targets
   - V2 is a toolchain and compatibility project, not a GPS spoofing project.

199. Deprecated active GPS/FakeGPS goals:
   - The following are no longer active project goals:
     Simple app-based GPS spoof controlled over SSH
     Editable coordinates
     System-wide spoof
     GPS preference UI
     CoreLocation/locationd spoofing
   - These remain possible future downstream applications, but they should not drive the repository or LogDoc structure.
   - Any future GPS-related work should be treated as a separate consumer project built on top of the validated toolchain, not as the core repository purpose.

200. Repository implication of V2 scope:
   - The Git repo should stop presenting itself as a FakeGPS project.
   - The repo should present itself as:
     a legacy iOS ARMv7 WSL/Linux toolchain toolkit and validation harness.
   - Suggested repo-facing language:
     Legacy iOS ARMv7 Toolchain Appliance / Toolkit for WSL Ubuntu.
   - Existing harmless examples remain appropriate:
     noop-tweak
     objc-runtime-test
     corefoundation-test
     foundation-test
     logos-hook-test
   - Application-specific GPS examples should not be added to this repo unless placed in a clearly separate downstream examples area later.
   - README/current status/device docs should describe:
     what is validated
     what is not validated
     how to reproduce
     how to validate
     what devices/SDKs are proven
     what remains experimental.

201. Current validated V2 baseline inherited from V1:
   - Reproducible legacy toolchain build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE
   - Mach-O stub generation:
     COMPLETE for current iOS 9.3 SDK host-link baseline
   - Host validation examples:
     COMPLETE
   - Full host validation pipeline:
     COMPLETE
   - WSL appliance export/import and restore validation:
     COMPLETE
   - NoOpTweak host package:
     COMPLETE
   - NoOpTweak device install/file placement/uninstall:
     COMPLETE as of later V1.24 work
   - NoOpTweak controlled runtime/respring lifecycle:
     COMPLETE as of later V1.25 work
   - LogosHookTest host package:
     COMPLETE host-side
   - LogosHookTest device runtime:
     next intended validation lane
   - FakeGPS implementation:
     removed from active scope.

202. Next high-level roadmap:
   - Step 1:
     Finish and push V2 repo-scope cleanup:
       README
       CURRENT_STATUS
       V1/V2 scope docs
       device docs
       remove or de-emphasize FakeGPS language.
   - Step 2:
     Preserve a V2 scope note in the LogDoc and repo.
   - Step 3:
     Run active artifact scan and validation sanity.
   - Step 4:
     Inspect LogosHookTest package.
   - Step 5:
     Perform controlled LogosHookTest device runtime lifecycle:
       install
       file placement
       respring
       normal return
       uninstall
       post-uninstall respring
       final clean state.
   - Step 6:
     Build a compatibility/edge-case matrix for:
       architectures
       SDK versions
       deployment targets
       framework symbols
       Theos/Logos patterns
       device runtime behaviors.
   - Step 7:
     Add more minimal validation examples only when they prove a reusable compatibility edge case.
   - Step 8:
     Later, test additional lost/common legacy iOS targets as separate lanes.

203. Recommended V2 validation lanes:
   - Lane A: iOS 6.1.3 / ARMv7 / iPhone 4s:
     current primary lane.
   - Lane B: older ARMv7 / iOS 5.x or 6.x:
     future only after lane A is stable.
   - Lane C: ARMv7s / iPhone 5-era:
     future only after build matrix is documented.
   - Lane D: arm64 early iOS 7/8:
     future, likely separate toolchain constraints.
   - Lane E: simulator/i386 legacy:
     optional, not priority.
   - No lane should be marked supported until:
     host build passes,
     package inspection passes,
     and device/runtime validation is performed where possible.

204. Updated risk boundary:
   - The major risk boundary is now compatibility claims.
   - Avoid claiming broad support for old iOS targets until tested.
   - Current proven target remains iPhone 4s / iOS 6.1.3 / ARMv7.
   - The WSL appliance proves one host environment, not every Linux/WSL version.
   - Mach-O stubs are host linker aids only.
   - Device runtime success on NoOpTweak does not prove Logos hook behavior.
   - Device runtime success on one target does not prove other targets.

205. What to avoid under V2:
   - Do not re-center the repo around FakeGPS.
   - Do not add GPS-specific code to the core validation repo.
   - Do not treat historical FakeGPS LogDoc entries as active scope.
   - Do not overclaim compatibility with other iOS versions/devices.
   - Do not skip package inspection before runtime tests.
   - Do not skip post-uninstall cleanup checks.
   - Do not let generated packages, logs, .theos directories, WSL tar exports, or private device pulls enter active Git paths.
   - Do not publish the private WSL export tar.

206. Suggested immediate repo changes:
   - Update README title/description to toolchain toolkit language.
   - Update CURRENT_STATUS to V2 scope.
   - Add docs/V2_SCOPE.md.
   - Add docs/TARGET_MATRIX.md.
   - Add docs/EDGE_CASE_TESTING_PLAN.md.
   - Keep DEVICE_INSTALL_SAFETY_PLAN.md but remove FakeGPS-first framing.
   - Keep DEVICE_TRANSFER_WORKFLOW.md.
   - Keep NOOP_RUNTIME_VALIDATION.md.
   - Keep LOGOS_RUNTIME_VALIDATION_PLAN.md.
   - Ensure active artifact scan remains clean.
   - Commit with message:
     Re-scope project as legacy iOS toolchain toolkit.

Breakpoint note:
   - V2.23 marks the official scope transition away from FakeGPS as the active goal.
   - The project is now a legacy iOS toolchain preservation, validation, and compatibility effort.
   - Next technical action should be repo re-scope cleanup, then LogosHookTest device runtime validation.


207. V2 git-side scope cleanup started:
   - User requested Git-side cleanup to match the new V2 LogDoc scope.
   - Input:
     current repository zip snapshot
     V2.23 LogDoc
   - Goal:
     make the active repository present as a legacy iOS ARMv7 toolchain toolkit, not a FakeGPS/product-specific project.
   - Environment decision:
     perform cleanup in the original Ubuntu WSL environment, not the restored appliance.
   - Reason:
     original Ubuntu remains the active development/workbench environment.
     restored appliance remains a frozen validation/fallback artifact.

208. V2 cleanup preflight plan:
   - A preflight script was generated:
     /tmp/00-v2-scope-preflight.sh
   - It checks:
     - git status
     - active scope wording
     - generated/private artifacts
     - script syntax
     - Python patcher compilation
   - Scope wording scan searched for:
     FakeGPS
     GPS spoof
     spoofing
     CoreLocation
     locationd
     System-wide spoof
     V1 host-side preservation scope
     V1 legacy iOS
   - Artifact scan excluded intentional obsolete/history folders:
     docs/obsolete-build-logs
     docs/obsolete-doc-snapshots
     docs/obsolete-example-sketches
     docs/obsolete-patch-sketches
   - Historical V1.21 appliance names were explicitly allowed because they refer to real export/import artifact names.

209. Added V2 scope docs:
   - Added:
     docs/V2_SCOPE.md
     docs/TARGET_MATRIX.md
     docs/EDGE_CASE_TESTING_PLAN.md
   - docs/V2_SCOPE.md defines the repository as:
     legacy iOS ARMv7 toolchain, validation, and preservation toolkit.
   - docs/V2_SCOPE.md explicitly says the active project is no longer a GPS spoofing tweak.
   - Active focus includes:
     - rebuilding legacy iOS ARMv7 toolchain on WSL/Linux
     - preserving WSL appliance
     - wiring Theos to the recovered toolchain
     - generating Mach-O stubs for old ld64
     - validating harmless package builds
     - validating controlled device-side install/runtime/uninstall lifecycles
     - expanding toward other common lost legacy iOS build targets
   - Out-of-scope items now include:
     - GPS spoofing as a product
     - CoreLocation/locationd spoofing
     - system-wide location spoofing
     - preference UI for spoofing
     - application-specific tweak behavior.

210. Added target matrix:
   - Added:
     docs/TARGET_MATRIX.md
   - Purpose:
     prevent overclaiming legacy iOS compatibility.
   - Matrix status labels:
     validated-host
     validated-device-install
     validated-device-runtime
     planned
     unknown
   - Current proven lane:
     Lane A:
       iPhone 4s
       iOS 6.1.3
       ARMv7
       host build validated
       NoOpTweak device install validated
       NoOpTweak runtime/respring validated
   - Next planned lane:
     A2:
       same iPhone 4s / iOS 6.1.3 / ARMv7 environment
       LogosHookTest device runtime validation.
   - Future lanes listed but not claimed:
     older ARMv7 iOS 5.x/6.x
     ARMv7s iPhone 5-era
     early arm64 iOS 7/8
     legacy simulator/i386
   - Rule:
     no lane should be marked supported without evidence.

211. Added edge-case testing plan:
   - Added:
     docs/EDGE_CASE_TESTING_PLAN.md
   - Purpose:
     define when new examples should be added.
   - Rules:
     examples should be minimal, harmless, reproducible, narrowly scoped, and documented.
   - Examples should not be:
     product features
     device-risky behavior
     broad system hooks
     application-specific logic
     preference/UI experiments unless the edge case is specifically preference loading.
   - Existing examples documented:
     noop-tweak
     objc-runtime-test
     corefoundation-test
     foundation-test
     logos-hook-test
   - Existing covered edge cases:
     ARMv7 toolchain smoke
     Theos no-op package
     Objective-C runtime symbol
     CoreFoundation symbol
     Foundation symbol
     Logos/MobileSubstrate host package
   - Current next edge case:
     LogosHookTest device runtime validation.
   - Instruction:
     do not add new examples until that boundary is crossed.

212. Active front-door docs rewritten for V2:
   - Rewrote:
     README.md
     docs/CURRENT_STATUS.md
   - README title changed to:
     Legacy iOS ARMv7 Toolchain Toolkit for WSL Ubuntu 24.04
   - README now states:
     V2 scope is legacy iOS ARMv7 toolchain preservation, validation, and compatibility testing.
   - README now explicitly says:
     repository is not an application-specific tweak project.
   - README current primary proven lane:
     iPhone 4s
     iOS 6.1.3
     ARMv7
     Cydia / MobileSubstrate
     Windows 11 + WSL Ubuntu 24.04 host
   - README validated list now includes:
     - toolchain build/install/verify
     - reproducible build script
     - Theos wrapper setup
     - Mach-O SDK stub generation
     - no-op .deb
     - Objective-C runtime .deb
     - CoreFoundation .deb
     - Foundation .deb
     - Logos/MobileSubstrate minimal hook .deb host-side
     - host validation pipeline
     - WSL export/import appliance preservation
     - restored appliance host validation
     - NoOpTweak device install/file-placement/uninstall
     - NoOpTweak controlled respring/runtime lifecycle
   - README not-yet-validated list now focuses on:
     - LogosHookTest device runtime behavior
     - generated Logos hook execution
     - hooked SpringBoard method behavior
     - preference bundles
     - additional iOS/device/architecture lanes
     - broad compatibility outside current Lane A.

213. Current status doc rewritten for V2:
   - Rewrote:
     docs/CURRENT_STATUS.md
   - It now defines current scope as:
     V2 legacy iOS ARMv7 toolchain preservation, validation, and compatibility testing.
   - It states the repo is:
     a toolchain toolkit and validation harness, not an application-specific tweak project.
   - Complete section now includes:
     - toolchain build/install/verify
     - fresh reproducible build
     - Theos wrapper setup
     - Mach-O stub generation
     - all host-side example packages
     - full host validation
     - WSL appliance export/import/restore validation
     - NoOpTweak device install/file-placement/uninstall
     - NoOpTweak controlled respring/runtime lifecycle
   - Not-yet-validated section now points to:
     LogosHookTest device runtime and future target lanes.

214. Device/runtime docs generalized away from GPS-product framing:
   - Updated:
     docs/DEVICE_INSTALL_SAFETY_PLAN.md
     docs/LOGOS_RUNTIME_VALIDATION_PLAN.md
     docs/NOOP_RUNTIME_VALIDATION.md
     docs/MACHO_STUBS.md
     docs/WSL_APPLIANCE_EXPORT.md
     docs/APPLIANCE_MANIFEST.md
     scripts/update-appliance-manifest.sh
   - Replaced active GPS-specific framing with application-specific or broad system behavior wording.
   - Example replacements:
     no FakeGPS logic yet -> no application-specific behavior yet
     GPS spoofing -> application-specific runtime behavior
     GPS spoof logic -> application-specific runtime logic
     CoreLocation spoofing -> broad system hook behavior
   - Historical references inside obsolete snapshots remain acceptable.

215. Obsolete snapshots created before V2 rewrite:
   - Saved pre-V2 versions under:
     docs/obsolete-doc-snapshots/
   - Snapshot targets included:
     README.pre-v2-scope.md
     CURRENT_STATUS.pre-v2-scope.md
     DEVICE_INSTALL_SAFETY_PLAN.pre-v2-scope.md
     MACHO_STUBS.pre-v2-scope.md
     LOGOS_RUNTIME_VALIDATION_PLAN.pre-v2-scope.md if present
     NOOP_RUNTIME_VALIDATION.pre-v2-scope.md if present
   - Purpose:
     preserve historical wording without allowing it to remain active front-door scope.
   - Rule:
     future scope scans should exclude docs/obsolete-* paths.

216. V2 scope sanity script generated:
   - Script:
     /tmp/03-v2-scope-sanity.sh
   - It runs:
     ./scripts/clean-generated-artifacts.sh
     active scope wording scan
     active V1 wording scan
     V1.21 appliance reference scan
     generated/private artifact scan
     bash syntax checks
     Python compile check
     git status
     diff stat
     cached diff stat
   - Expected interpretation:
     active scope wording scan should be empty or only show acceptable non-active context.
     V1.21 appliance references are okay in appliance docs/scripts.
     active generated/private artifact scan should be empty.

217. Host validation after V2 doc cleanup:
   - User ran host pipeline after doc cleanup.
   - Validation output reached:
     Host pipeline validation complete.
   - Package artifacts were produced for:
     foundation-test:
       com.bitcrusher32.foundationtest_0.0.1-1+debug_iphoneos-arm.deb
     corefoundation-test:
       com.bitcrusher32.corefoundationtest_0.0.1-1+debug_iphoneos-arm.deb
     objc-runtime-test:
       com.bitcrusher32.objcruntimetest_0.0.1-1+debug_iphoneos-arm.deb
     noop-tweak:
       com.bitcrusher32.nooptweak_0.0.1-1+debug_iphoneos-arm.deb
     logos-hook-test:
       com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - Cleanup script then removed generated Theos/example artifacts, local validation logs, and Python caches.
   - Final visible git state showed only the three new V2 docs untracked:
     docs/EDGE_CASE_TESTING_PLAN.md
     docs/TARGET_MATRIX.md
     docs/V2_SCOPE.md
   - Interpretation:
     host pipeline is still green after V2 docs/scope cleanup.
     generated artifacts were successfully cleaned.
     remaining work before push is staging/committing the intended V2 docs and any active doc modifications.

218. Commit guidance for V2 cleanup:
   - Because the three V2 docs were untracked, next safe staging command:
     git add docs/V2_SCOPE.md docs/TARGET_MATRIX.md docs/EDGE_CASE_TESTING_PLAN.md
   - If README/status/device doc rewrites are still unstaged, include them as well:
     git add README.md docs scripts examples .gitignore
   - Check staged diff:
     git diff --cached --stat
     git diff --cached -- docs/V2_SCOPE.md docs/TARGET_MATRIX.md docs/EDGE_CASE_TESTING_PLAN.md
   - Suggested commit messages:
     if only three docs are staged:
       Add V2 scope and target planning docs
     if full rewrite is staged:
       Re-scope project as legacy iOS toolchain toolkit
   - User intentionally held off on pushing until LogDoc V2.24 captured the scope cleanup.

219. Current V2.24 project posture:
   - Active project identity:
     Legacy iOS ARMv7 Toolchain Toolkit.
   - Current primary lane:
     iPhone 4s / iOS 6.1.3 / ARMv7.
   - Core repo identity:
     reproducible build, validation, and preservation toolkit.
   - Downstream application-specific projects are out of core scope.
   - Host pipeline remains green after scope docs.
   - No new device install occurred during V2 cleanup.
   - Next technical boundary remains:
     LogosHookTest package inspection, then controlled device runtime validation.

220. Things to avoid after V2.24:
   - Do not push before checking staged diff.
   - Do not include generated .deb/packages/.theos/log artifacts.
   - Do not allow active README/status docs to re-center on FakeGPS/GPS spoofing.
   - Do not claim support for future iOS/device lanes from the matrix until validated.
   - Do not treat obsolete snapshot wording as active documentation.
   - Do not start LogosHookTest install before host package inspection.
   - Do not add application-specific examples to the core toolkit until a separate downstream structure is deliberately created.

Breakpoint note:
   - V2.24 captures the Git-side scope cleanup and green host validation after that cleanup.
   - The repo is ready to commit/push the V2 scope docs once staged diff is reviewed.
   - After the commit, proceed to LogosHookTest inspection only, then decide on runtime validation.


221. LogosHookTest package inspection performed:
   - After the V2.24 Git-side scope cleanup, the next technical boundary was LogosHookTest inspection.
   - Scope remained:
     package inspection first, no install until the package contents and Mach-O metadata looked acceptable.
   - Host validation was run first:
     ./scripts/validate-host-pipeline.sh
   - Host pipeline produced packages for:
     noop-tweak
     objc-runtime-test
     corefoundation-test
     foundation-test
     logos-hook-test
   - LogosHookTest package inspected:
     examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - Inspection command:
     ./scripts/inspect-deb-package.sh examples/logos-hook-test/packages/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

222. LogosHookTest package metadata:
   - Package:
     com.bitcrusher32.logoshooktest
   - Name:
     LogosHookTest
   - Description:
     Minimal Logos hook compile/link/package validation.
   - Depends:
     mobilesubstrate
   - Architecture:
     iphoneos-arm
   - Version:
     0.0.1-1+debug
   - Installed-Size:
     56
   - Package format:
     Debian binary package format 2.0 with control.tar.gz and lzma data compression.
   - Package size:
     about 2.2K / 2168 bytes in the inspected build.

223. LogosHookTest payload inspection:
   - Payload files:
     /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.dylib
     /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.plist
   - Dylib size:
     34256 bytes
   - Plist size:
     93 bytes
   - Safety red-flag paths:
     none
   - Maintainer scripts:
     none
   - Interpretation:
     The package only places the expected MobileSubstrate dylib/plist pair and does not install LaunchDaemons, preference bundles, system binaries, maintainer scripts, or unexpected files.
   - This made it acceptable for a controlled device install/file-placement test.

224. LogosHookTest Mach-O inspection:
   - LogosHookTest.dylib identified as:
     Mach-O armv7 dynamically linked shared library
   - Flags:
     NOUNDEFS
     DYLDLINK
     TWOLEVEL
     NO_REEXPORTED_DYLIBS
   - Load commands included:
     /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.dylib
     /usr/lib/libobjc.A.dylib
     /System/Library/Frameworks/Foundation.framework/Foundation
     /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
     /usr/lib/libSystem.B.dylib
     /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
   - Undefined symbols:
     _MSHookMessageEx
     _objc_getClass
     dyld_stub_binder
   - Interpretation:
     _MSHookMessageEx is expected to resolve through CydiaSubstrate/MobileSubstrate.
     _objc_getClass is expected to resolve through libobjc runtime.
     dyld_stub_binder is expected through libSystem/dyld lazy binding.
   - These undefined symbols matched the expected runtime-resolved pattern already reasoned about during WeatherX and NoOpTweak investigations.

225. LogosHookTest source/plist confirmation:
   - Source tree inspected before device install:
     examples/logos-hook-test/Makefile
     examples/logos-hook-test/LogosHookTest.plist
     examples/logos-hook-test/control
     examples/logos-hook-test/Tweak.xm
   - Makefile target:
     ARCHS = armv7
     TARGET = iphone:clang:9.3:6.1
   - Tweak name:
     LogosHookTest
   - Source file:
     Tweak.xm
   - Plist filter:
     Bundles = (
       "com.apple.springboard"
     );
   - Hook source:
     %hook SpringBoard
     - (void)applicationDidFinishLaunching:(id)application {
         %orig;
     }
     %end
   - Interpretation:
     This is the lowest-risk real Logos runtime test currently available:
       targets SpringBoard only,
       hooks applicationDidFinishLaunching:,
       immediately calls %orig,
       adds no side effects,
       writes no files,
       changes no behavior intentionally.
   - Decision:
     proceed to controlled install/file-placement only, then decide separately on respring.

226. LogosHookTest transfer path:
   - Reused known-good device workflow:
     WSL build
     -> /mnt/c/iPhone4sPush/
     -> Windows PowerShell pscp.exe
     -> iPhone /var/root/
     -> PuTTY root shell
     -> dpkg install/remove/checks
   - WSL SSH/SCP remained intentionally avoided because Windows PuTTY/pscp path was the proven device control chain.
   - Package copied to Windows bridge:
     /mnt/c/iPhone4sPush/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - Package transferred to device:
     /var/root/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb

227. LogosHookTest device install/file-placement test succeeded:
   - Device command:
     dpkg -i /var/root/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - dpkg output:
     Selecting previously unselected package com.bitcrusher32.logoshooktest.
     Preparing to unpack ...
     Unpacking com.bitcrusher32.logoshooktest (0.0.1-1+debug) ...
     Setting up com.bitcrusher32.logoshooktest (0.0.1-1+debug) ...
   - Installed package check:
     dpkg -l | grep -i bitcrusher32
   - Result:
     ii  com.bitcrusher32.logoshooktest 0.0.1-1+debug iphoneos-arm
     Minimal Logos hook compile/link/package validation.
   - File placement:
     /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.dylib
     /Library/MobileSubstrate/DynamicLibraries/LogosHookTest.plist
   - File details:
     LogosHookTest.dylib:
       root wheel
       34256 bytes
       executable
     LogosHookTest.plist:
       root wheel
       93 bytes
   - Interpretation:
     LogosHookTest passed the same package transfer, dpkg acceptance, registration, and MobileSubstrate file-placement checks as NoOpTweak.

228. LogosHookTest controlled SpringBoard runtime/respring test succeeded:
   - Command:
     killall SpringBoard
   - Physical device behavior:
     screen went black,
     startup sound occurred,
     Apple logo appeared,
     device loaded to unlock screen,
     user unlocked normally.
   - No reported:
     boot loop
     stuck Apple logo
     Safe Mode alert
     visible instability
   - Post-respring package check:
     dpkg -l | grep -i bitcrusher32
   - Result:
     com.bitcrusher32.logoshooktest remained installed.
   - Post-respring file check:
     LogosHookTest.dylib and LogosHookTest.plist remained present.
   - Interpretation:
     The generated Logos/MobileSubstrate hook package survived SpringBoard runtime loading on the real iPhone 4s / iOS 6.1.3 / ARMv7 lane.
   - This crosses the boundary that NoOpTweak did not prove:
     a generated Logos hook package can be installed, loaded into the target process, and survive a controlled SpringBoard restart.

229. LogosHookTest uninstall and cleanup succeeded:
   - Device command:
     dpkg -r com.bitcrusher32.logoshooktest
   - dpkg output:
     Removing com.bitcrusher32.logoshooktest (0.0.1-1+debug) ...
   - Package-after-uninstall check:
     dpkg -l | grep -i bitcrusher32 || true
   - Result:
     no bitcrusher32 package listed.
   - Files-after-uninstall check:
     ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i LogosHookTest || true
   - Result:
     no LogosHookTest dylib/plist listed.
   - Copied package cleanup:
     rm -f /var/root/com.bitcrusher32.logoshooktest_0.0.1-1+debug_iphoneos-arm.deb
   - Verification:
     ls reported no such file, which is expected after cleanup.

230. LogosHookTest post-uninstall respring and final clean state:
   - Command:
     killall SpringBoard
   - Final package check after post-uninstall respring:
     dpkg -l | grep -i bitcrusher32 || true
   - Result:
     no bitcrusher32 package listed.
   - Final files check:
     ls -la /Library/MobileSubstrate/DynamicLibraries/ | grep -i LogosHookTest || true
   - Result:
     no LogosHookTest files listed.
   - Interpretation:
     Device returned to a clean state after:
       install
       file placement
       controlled SpringBoard respring
       runtime tolerance
       uninstall
       copied .deb cleanup
       post-uninstall respring
       final clean package/file check.

231. V2.25 milestone significance:
   - This is one of the largest project milestones so far.
   - Validated full Logos lifecycle:
     host build
     host package inspection
     source/plist confirmation
     Windows bridge transfer
     device dpkg install
     MobileSubstrate file placement
     controlled SpringBoard respring with generated Logos hook present
     normal device return
     package persistence after respring
     clean uninstall
     copied .deb cleanup
     post-uninstall respring
     final clean state
   - This proves more than NoOpTweak:
     NoOpTweak proved generated package runtime tolerance.
     LogosHookTest proves generated Logos/MobileSubstrate hook runtime tolerance for the primary lane.
   - Current proven lane:
     iPhone 4s / iOS 6.1.3 / ARMv7 now has:
       toolchain validation,
       host Theos validation,
       Mach-O stub validation,
       no-op device runtime validation,
       Logos hook device runtime validation.

232. Updated validated ladder after V2.25:
   - Toolchain reproducible build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE
   - Mach-O stub generation:
     COMPLETE for current baseline
   - Repo-hosted host validation examples:
     COMPLETE
   - Full host validation pipeline:
     COMPLETE
   - WSL appliance export/import/restore validation:
     COMPLETE
   - NoOpTweak host package:
     COMPLETE
   - NoOpTweak package inspection:
     COMPLETE
   - NoOpTweak device install/file placement/uninstall:
     COMPLETE
   - NoOpTweak controlled runtime/respring lifecycle:
     COMPLETE
   - LogosHookTest host package:
     COMPLETE
   - LogosHookTest package inspection:
     COMPLETE
   - LogosHookTest source/plist confirmation:
     COMPLETE
   - LogosHookTest device install/file placement:
     COMPLETE
   - LogosHookTest controlled SpringBoard runtime/respring lifecycle:
     COMPLETE
   - LogosHookTest uninstall/post-uninstall clean state:
     COMPLETE
   - Logging-only hook:
     NOT STARTED
   - Additional target lanes:
     NOT STARTED

233. Current project meaning after V2.25:
   - The core recovered toolchain is no longer merely host-side viable.
   - It has produced a generated Logos/MobileSubstrate tweak package that survived runtime loading on the real target device.
   - This makes the current Lane A a real validated toolchain/runtime lane:
     WSL/Linux host
     legacy ARMv7 toolchain
     Theos package generation
     iOS 6.1.3 device package lifecycle
     MobileSubstrate/Logos runtime loading.
   - The next boundary is observability, not basic runtime survival.
   - A sensible next edge case is a logging-only hook that proves the generated hook body executes, without modifying system behavior.

234. Recommended next branch after V2.25:
   - Do not jump to application-specific tweak behavior yet.
   - Next safer milestone:
     create a logging-only Logos hook test.
   - Requirements:
     - minimal hook body
     - no behavior changes
     - call %orig
     - write a single marker or append a tiny line to a controlled path
     - inspect package
     - install
     - respring
     - confirm marker/log
     - uninstall
     - post-uninstall respring
     - final clean state
   - Candidate marker paths should be chosen carefully:
     /var/mobile/Library/Logs/
     or another low-risk writable path.
   - Avoid:
     noisy logging loops
     broad hooks
     daemon hooks
     preference bundles
     application-specific logic
     additional target lane claims before testing.

235. Things to avoid after V2.25:
   - Do not treat LogosHookTest as proof that arbitrary hooks are safe.
   - Do not add behavior-changing examples yet.
   - Do not leave LogosHookTest installed after validation.
   - Do not forget package inspection before every new device test.
   - Do not skip final clean checks after uninstall.
   - Do not let generated packages/logs/.theos directories enter Git.
   - Do not claim other iOS versions/devices are validated.
   - Do not re-center the repo around downstream application-specific behavior.

Breakpoint note:
   - V2.25 marks the first successful generated Logos/MobileSubstrate hook lifecycle on the real iPhone 4s / iOS 6.1.3 target.
   - The repo/toolchain now has host-side, no-op runtime, and Logos runtime validation on Lane A.
   - Next technical action should be Git-side documentation updates for this milestone, then a logging-only hook edge-case plan.


236. Logging-only hook observability branch started:
   - After V2.25 validated LogosHookTest runtime loading, the next planned edge case was observability.
   - Goal:
     prove the generated hook body actually executes, while avoiding behavior-changing logic.
   - New example target:
     examples/logos-logging-test
   - Package:
     com.bitcrusher32.logosloggingtest
   - Tweak:
     LogosLoggingTest
   - Scope:
     minimal SpringBoard hook
     call %orig
     write a small marker file
     no behavior changes
     no preference bundle
     no daemon hook
     no broad system hook
     no application-specific behavior.
   - Intended marker:
     /var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt
   - Known-good runtime lane remains:
     iPhone 4s / iOS 6.1.3 / ARMv7 / MobileSubstrate.

237. Initial logging test example created:
   - Created files:
     examples/logos-logging-test/Makefile
     examples/logos-logging-test/control
     examples/logos-logging-test/LogosLoggingTest.plist
     examples/logos-logging-test/Tweak.xm
   - Makefile target:
     ARCHS = armv7
     TARGET = iphone:clang:9.3:6.1
   - Package control:
     Package: com.bitcrusher32.logosloggingtest
     Name: LogosLoggingTest
     Version: 0.0.1
     Architecture: iphoneos-arm
     Description: Minimal Logos hook runtime observability validation.
     Depends: mobilesubstrate
   - Plist filter:
     com.apple.springboard
   - Initial implementation attempted Foundation/Objective-C file writing:
     import Foundation
     @autoreleasepool
     NSString marker path/message
     [message writeToFile:atomically:encoding:error:]
   - This was intentionally simple but pulled in a larger Objective-C/Foundation runtime surface than previous examples.

238. First pipeline issue: new example existed but was not added to validation pipeline:
   - Existence check showed:
     examples/logos-logging-test existed
     Makefile/control/plist/Tweak.xm existed
   - Pipeline scan showed only:
     build_example "logos-hook-test"
   - Missing:
     build_example "logos-logging-test"
   - Result:
     validate-host-pipeline.sh did not build the new package.
   - The inspect command then looked for a package that did not exist:
     examples/logos-logging-test/packages/com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - Diagnosis:
     not a dependency issue;
     the new example had simply not been wired into scripts/validate-host-pipeline.sh.
   - Fix:
     add an eighth pipeline stage:
       echo "=== [8/8] Logos logging test ==="
       build_example "logos-logging-test"
     and adjust the Logos hook stage label to:
       === [7/8] Logos hook test ===

239. Second issue: Foundation/Objective-C implementation exposed missing Objective-C runtime symbols:
   - After wiring logos-logging-test into the host validation pipeline, the first implementation reached compile/link but failed at link time.
   - Undefined symbols included:
     _objc_autoreleasePoolPop
     _objc_autoreleasePoolPush
     _objc_msgSend
   - Cause:
     @autoreleasepool, NSString, and writeToFile: pulled in Objective-C message sending and autorelease pool runtime calls.
   - Existing host-side libobjc Mach-O stub was intentionally tiny and only covered earlier requirements such as:
     _objc_getClass
   - Interpretation:
     this was a legitimate new edge case, but it was too large for the next safe observability test.
   - Decision:
     avoid Foundation/Objective-C message-sending for the logging marker.
     Use plain C/POSIX file I/O instead.

240. Third issue: manual POSIX declarations conflicted with SDK headers:
   - First POSIX rewrite manually declared:
     extern "C" int open(...)
     extern "C" int write(...)
     extern "C" int close(...)
   - Compile failed because the SDK already declared write() through unistd.h:
     ssize_t write(int, const void *, size_t)
   - Error:
     functions that differ only in their return type cannot be overloaded
   - Cause:
     manual declaration used int return type for write(),
     while SDK declared ssize_t.
   - Fix:
     remove manual declarations and include real SDK headers:
       #include <fcntl.h>
       #include <unistd.h>
       #include <string.h>
   - This changed the issue from a compile type-conflict into a pure linker-symbol edge case.

241. Fourth issue: POSIX logging implementation required additional libSystem stub exports:
   - POSIX implementation compiled, then failed at link time.
   - Undefined symbols:
     _close
     _open
     _strlen
     _write
   - Cause:
     host-side libSystem Mach-O stub only exported the minimal symbol surface needed so far:
       dyld_stub_binder
   - The generated dylib should resolve open/write/close through libSystem at device runtime, but old ld64 needs host-side Mach-O symbols during link.
   - First reduction:
     remove strlen() by using a constant byte count for the marker message.
   - Remaining expected POSIX symbols:
     _open
     _write
     _close
   - Interpretation:
     this was a useful reusable edge case for the toolchain:
     minimal POSIX file marker from a Logos hook needs host-side libSystem stub symbols.

242. libSystem Mach-O stub expanded:
   - Updated:
     scripts/build-ios-machostubs.sh
   - Added host-side stub exports to the generated libSystem.dylib:
     _open
     _write
     _close
   - Existing symbol retained:
     dyld_stub_binder
   - Important:
     these are host linker shims only.
     They are not runtime implementations.
     The real iOS device provides libSystem at runtime.
   - Stub verification now prints:
     dyld_stub_binder
     _open
     _write
     _close
   - This keeps the project aligned with the V2 scope:
     add minimal symbols only when a validation example proves they are needed.

243. Final logging test implementation after reductions:
   - Current Tweak.xm uses:
     #include <fcntl.h>
     #include <unistd.h>
   - Hook:
     %hook SpringBoard
     - (void)applicationDidFinishLaunching:(id)application {
         %orig;
         const char *path = "/var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt";
         const char *msg = "LogosLoggingTest marker: SpringBoard applicationDidFinishLaunching executed.\n";
         int fd = open(path, O_WRONLY | O_CREAT | O_APPEND, 0644);
         if (fd >= 0) {
             write(fd, msg, 75);
             close(fd);
         }
     }
     %end
   - Characteristics:
     no Foundation object use
     no Objective-C message sends beyond the Logos hook machinery
     no autorelease pool
     no strlen dependency
     calls %orig first
     appends a small marker line
   - Note:
     the hardcoded length should be kept under review if the marker string changes.

244. Logging package build and inspection succeeded:
   - Generated package:
     examples/logos-logging-test/packages/com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - Package size:
     2366 bytes / about 2.4K
   - Metadata:
     Package: com.bitcrusher32.logosloggingtest
     Name: LogosLoggingTest
     Description: Minimal Logos hook runtime observability validation.
     Depends: mobilesubstrate
     Architecture: iphoneos-arm
     Version: 0.0.1-1+debug
     Installed-Size: 56
   - Package format:
     Debian binary package format 2.0 with control.tar.gz and lzma data compression.
   - Payload:
     /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.dylib
     /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.plist
   - Payload sizes:
     LogosLoggingTest.dylib: 34384 bytes
     LogosLoggingTest.plist: 93 bytes

245. Logging package safety inspection:
   - Safety red-flag paths:
     none
   - Maintainer scripts:
     none
   - Extracted data tree contained only:
     LogosLoggingTest.dylib
     LogosLoggingTest.plist
   - Interpretation:
     package is clean enough for a controlled device install/file-placement test.
   - No LaunchDaemons.
   - No preference bundles.
   - No unexpected system paths.
   - No maintainer scripts.
   - No application-specific behavior beyond the marker write inside SpringBoard after %orig.

246. Logging package Mach-O inspection:
   - Dylib:
     Mach-O armv7 dynamically linked shared library
   - Flags:
     NOUNDEFS
     DYLDLINK
     TWOLEVEL
     NO_REEXPORTED_DYLIBS
   - Load commands:
     /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.dylib
     /usr/lib/libobjc.A.dylib
     /System/Library/Frameworks/Foundation.framework/Foundation
     /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation
     /usr/lib/libSystem.B.dylib
     /Library/Frameworks/CydiaSubstrate.framework/CydiaSubstrate
   - Undefined symbols:
     _MSHookMessageEx
     _close
     _objc_getClass
     _open
     _write
     dyld_stub_binder
   - Interpretation:
     _MSHookMessageEx resolves through CydiaSubstrate/MobileSubstrate.
     _objc_getClass resolves through libobjc.
     _open/_write/_close and dyld_stub_binder resolve through libSystem/dyld at runtime.
   - The expected libSystem load command is present.
   - The earlier problematic Objective-C/Foundation symbols are no longer present:
     no _objc_msgSend
     no _objc_autoreleasePoolPush
     no _objc_autoreleasePoolPop
   - This confirms the POSIX/minimal marker rewrite did its job.

247. V2.26 milestone significance:
   - V2.25 proved a generated Logos hook package could survive runtime loading.
   - V2.26 proves the next host-side edge case:
     a generated Logos hook package with minimal observability can be built and inspected cleanly.
   - It also improved the toolchain's host linker compatibility by expanding libSystem stub coverage for minimal POSIX file I/O.
   - This is still pre-device for LogosLoggingTest:
     no install yet
     no respring yet
     no marker file has been observed yet.
   - The next device-side milestone is:
     install LogosLoggingTest
     confirm file placement
     controlled respring
     confirm marker file exists
     uninstall
     post-uninstall respring
     final clean state.

248. Updated validated ladder after V2.26:
   - Toolchain reproducible build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE
   - Mach-O stub generation:
     COMPLETE for current baseline
   - libSystem host-side stub exports for dyld_stub_binder/open/write/close:
     COMPLETE
   - Repo-hosted host validation examples through LogosHookTest:
     COMPLETE
   - LogosLoggingTest host build:
     COMPLETE
   - LogosLoggingTest package inspection:
     COMPLETE
   - NoOpTweak device runtime:
     COMPLETE
   - LogosHookTest device runtime:
     COMPLETE
   - LogosLoggingTest device runtime/marker observability:
     NOT ATTEMPTED
   - Additional target lanes:
     NOT STARTED

249. Repo implications after V2.26:
   - Add/keep:
     examples/logos-logging-test
   - Update:
     scripts/validate-host-pipeline.sh
     scripts/build-ios-machostubs.sh
     docs/EDGE_CASE_TESTING_PLAN.md
     docs/CURRENT_STATUS.md
     docs/TARGET_MATRIX.md if desired after device success
   - Do not claim logging observability validated on device yet.
   - Current accurate status:
     logging-only hook host build and package inspection validated.
   - Device validation should occur before marking runtime observability complete.

250. Things to avoid after V2.26:
   - Do not install before copying the exact inspected package through the known-good transfer path.
   - Do not assume marker creation works just because host inspection passed.
   - Do not leave the marker file behind without noting it or cleaning it deliberately.
   - Do not add noisy logging.
   - Do not use Foundation/NSString/writeToFile in this minimal edge case unless intentionally expanding libobjc/Foundation stubs later.
   - Do not over-expand host stubs with broad symbol lists; add symbols only when a minimal validation example requires them.
   - Do not mark additional target lanes as supported from this result.
   - Do not commit generated packages, .theos directories, inspection logs, or validation logs.

Breakpoint note:
   - V2.26 marks the logging-only hook host-build/inspection breakpoint.
   - The previous failures were valuable:
     missing pipeline entry,
     Objective-C runtime symbol expansion,
     POSIX declaration conflict,
     missing libSystem POSIX stub exports.
   - The next action should be controlled device install/runtime marker validation for LogosLoggingTest.


251. LogosLoggingTest device install/file-placement validation:
   - After V2.26 host build/inspection succeeded, the next device boundary was controlled install and file placement.
   - Known-good transfer path reused:
     WSL build/package
     -> /mnt/c/iPhone4sPush/
     -> Windows PowerShell pscp.exe
     -> iPhone /var/root/
     -> PuTTY root shell
     -> dpkg install/remove/checks
   - Exact package:
     com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - Device location:
     /var/root/com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - Package arrived check:
     file present as root:wheel, size 2366 bytes.
   - Pre-existing marker check:
     /var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt
     absent before runtime test.
   - This confirmed the later marker would be attributable to the hook execution test rather than an old leftover file.

252. LogosLoggingTest package install result:
   - Device command:
     dpkg -i /var/root/com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - dpkg output showed:
     Preparing to unpack ...
     Unpacking com.bitcrusher32.logosloggingtest (0.0.1-1+debug) over (0.0.1-1+debug) ...
     Setting up com.bitcrusher32.logosloggingtest (0.0.1-1+debug) ...
   - Note:
     The "over" wording means the same version had already been installed before this run.
     This was acceptable because the current package state and pre-respring marker absence were verified.
   - Installed package check:
     dpkg -l | grep -i bitcrusher32
   - Result:
     ii  com.bitcrusher32.logosloggingtest 0.0.1-1+debug iphoneos-arm
     Minimal Logos hook runtime observability validation.
   - File placement:
     /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.dylib
     /Library/MobileSubstrate/DynamicLibraries/LogosLoggingTest.plist
   - File details:
     LogosLoggingTest.dylib:
       root wheel
       34384 bytes
       executable
     LogosLoggingTest.plist:
       root wheel
       93 bytes
   - Marker before respring:
     absent.
   - Interpretation:
     install and file placement passed cleanly.

253. LogosLoggingTest controlled runtime/respring test:
   - Command:
     killall SpringBoard
   - Physical device behavior:
     phone went dark,
     startup sound played,
     Apple boot logo appeared,
     device returned to login/lock screen.
   - No reported:
     boot loop
     stuck Apple logo
     Safe Mode alert
     visible instability.
   - Post-respring file check:
     LogosLoggingTest.dylib and LogosLoggingTest.plist remained present.
   - Marker check:
     /var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt
     existed after respring.
   - Marker ownership/size:
     mobile mobile
     75 bytes.
   - Marker content:
     LogosLoggingTest marker: SpringBoard applicationDidFinishLaunching executed.
   - Interpretation:
     The generated Logos hook body executed on the real target device.
   - This is the first validated observability milestone:
     not merely package loading,
     not merely respring tolerance,
     but confirmed hook-body execution.

254. LogosLoggingTest uninstall / clean exit path:
   - User reported cleanup successful after the marker proof.
   - Clean exit path performed:
     dpkg -r com.bitcrusher32.logosloggingtest
     package-after-uninstall check
     DynamicLibraries file-after-uninstall check
     marker cleanup
     copied .deb cleanup
     post-uninstall SpringBoard respring
     final package/file/marker checks.
   - Expected final clean state:
     no bitcrusher32 package listed
     no LogosLoggingTest.dylib/plist under DynamicLibraries
     no marker file at:
       /var/mobile/Library/Logs/bitcrusher32-logoshook-marker.txt
     no copied package under:
       /var/root/com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - Interpretation:
     LogosLoggingTest completed the same controlled lifecycle standard as NoOpTweak and LogosHookTest, with the added marker-observability proof.

255. V2.27 major milestone significance:
   - V2.25 proved generated Logos/MobileSubstrate runtime loading.
   - V2.26 proved logging-only hook host build/package inspection.
   - V2.27 proves logging-only hook execution/observability on-device.
   - The validated chain is now:
     host build
     host package inspection
     known-good transfer
     dpkg install
     MobileSubstrate file placement
     controlled SpringBoard respring
     SpringBoard returns normally
     hook body writes marker
     marker content confirms execution
     uninstall
     marker cleanup
     post-uninstall clean state.
   - Current primary lane status:
     iPhone 4s / iOS 6.1.3 / ARMv7 now validates:
       toolchain build/install/verify,
       Theos wrapper setup,
       Mach-O stub generation,
       host package validation,
       no-op device runtime lifecycle,
       generated Logos hook runtime lifecycle,
       generated Logos hook body observability.

256. Updated validated ladder after V2.27:
   - Toolchain reproducible build/install/verify:
     COMPLETE
   - Theos wrapper setup:
     COMPLETE
   - Mach-O stub generation:
     COMPLETE for current baseline
   - libSystem host-side stub exports for dyld_stub_binder/open/write/close:
     COMPLETE
   - Full host validation pipeline:
     COMPLETE through LogosLoggingTest after pipeline update
   - NoOpTweak device lifecycle:
     COMPLETE
   - LogosHookTest device lifecycle:
     COMPLETE
   - LogosLoggingTest host build/inspection:
     COMPLETE
   - LogosLoggingTest device install/file placement:
     COMPLETE
   - LogosLoggingTest controlled runtime/respring:
     COMPLETE
   - LogosLoggingTest marker observability:
     COMPLETE
   - LogosLoggingTest uninstall/post-uninstall clean state:
     COMPLETE, per user report
   - Behavior-changing hook:
     NOT STARTED
   - Preference bundle:
     NOT STARTED
   - Additional target lanes:
     NOT STARTED.

257. Repo implications after V2.27:
   - Add:
     examples/logos-logging-test/
   - Update:
     scripts/validate-host-pipeline.sh
       to include logos-logging-test as the eighth validation lane.
     scripts/build-ios-machostubs.sh
       to include _open/_write/_close in libSystem stub generation.
     docs/CURRENT_STATUS.md
       to mark logging-only hook execution/observability as validated.
     docs/EDGE_CASE_TESTING_PLAN.md
       to record the logging-only hook edge case as completed.
     docs/TARGET_MATRIX.md
       to update Lane A/A2 or add a logging observability validation row.
     docs/LOGOS_RUNTIME_VALIDATION.md
       to either include a logging-only section or add a separate LOGOS_LOGGING_VALIDATION.md.
     README.md
       to list LogosLoggingTest as validated after device marker proof.
   - Do not commit generated:
     packages/
     .theos/
     *.deb
     validate logs
     inspect logs.

258. Technical lessons from V2.27:
   - Keep validation examples intentionally small.
   - Foundation/NSString writeToFile was too wide for this edge case and introduced Objective-C runtime symbols.
   - Plain POSIX open/write/close was the better minimal observability path.
   - The host stub model should grow only as necessary.
   - Adding _open/_write/_close to libSystem was justified by a minimal validation example.
   - Pre-respring marker absence is a useful guard against false positives.
   - Marker cleanup should be part of every observability test.

259. Next recommended goals after V2.27:
   - First:
     Git cleanup, docs update, sanity scan, commit, push.
   - Then:
     Consider a more durable validation framework:
       - device test checklist docs
       - naming/versioning convention for examples
       - one script to build/copy exact package to Windows bridge
       - optional manifest of last inspected package filename/hash.
   - Next technical edge cases:
     A. Runtime-safe repeated respring test:
        install LogosLoggingTest, respring twice, verify marker appends twice, uninstall/clean.
        This tests repeatability without new behavior.
     B. Controlled non-SpringBoard target:
        choose a very low-risk app/process only if needed.
        Not urgent.
     C. UIKit or PreferenceLoader host-only validation:
        only if the project needs UI/config packaging later.
     D. Start target-matrix research:
        document iOS 5/6 ARMv7, ARMv7s, and early arm64 lanes without claiming support.
     E. Export a new private WSL appliance after V2.27 repo is committed and host validation is green.
   - Avoid behavior-changing hooks until documentation and cleanup are committed.

260. Things to avoid after V2.27:
   - Do not jump directly to behavior-changing tweaks.
   - Do not leave marker files behind.
   - Do not leave test packages installed.
   - Do not add broad ObjC/Foundation stub symbols without minimal tests.
   - Do not claim other devices/iOS versions are supported.
   - Do not commit generated packages, Theos build trees, copied .debs, logs, or WSL exports.
   - Do not forget that the WSL export remains private and should not be published.

Breakpoint note:
   - V2.27 marks the first confirmed generated Logos hook body execution on the real iPhone 4s / iOS 6.1.3 / ARMv7 lane.
   - The project has crossed from toolchain recovery into verified runtime observability.
   - Next action:
     update repo docs/scripts/examples for V2.27, run cleanup/sanity, commit/push, then decide the next edge-case lane.


261. Workflow hardening branch started:
   - After V2.27 confirmed generated Logos hook-body execution on the real target device, the next agreed branch was workflow hardening.
   - Goal:
     reduce copy/paste risk in the build -> inspect -> stage-to-Windows workflow.
   - New script added:
     scripts/build-inspect-stage-example.sh
   - Script purpose:
     build a named example,
     inspect the exact produced .deb,
     copy that exact .deb to /mnt/c/iPhone4sPush,
     write a small manifest beside the staged package.
   - Intended use:
     ./scripts/build-inspect-stage-example.sh logos-logging-test
   - This is not a device install script.
   - It deliberately stops before PowerShell pscp and before any PuTTY/dpkg device action.

262. build-inspect-stage-example.sh behavior:
   - Validates that an example name was passed.
   - Verifies:
     examples/<name> exists
     examples/<name>/Makefile exists
   - Runs cleanup first:
     scripts/clean-generated-artifacts.sh
   - Rebuilds Theos wrappers:
     scripts/setup-theos-toolchain-links.sh
   - Rebuilds Mach-O stubs:
     scripts/build-ios-machostubs.sh
   - Runs:
     make clean
     make package messages=yes
     inside the selected example directory.
   - Locates the newest produced .deb under:
     examples/<name>/packages/
   - Runs:
     scripts/inspect-deb-package.sh
   - Writes inspection log:
     inspect-<example>.log
   - Copies the exact .deb to:
     /mnt/c/iPhone4sPush/
   - Writes a Windows-stage manifest:
     /mnt/c/iPhone4sPush/<deb-name>.manifest.txt
   - Manifest includes:
     example
     repo path
     source .deb path
     staged .deb path
     staged timestamp
     sha256
     byte size.
   - Prints the suggested PowerShell pscp command with an <IPHONE_IP> placeholder.

263. Workflow hardening cleanup issue found:
   - After running the workflow hardening script and cleanup, active artifact scan found:
     ./inspect-logos-logging-test.log
     ./inspect-logosloggingtest-1.log
   - Interpretation:
     generated inspection logs were still in the active repo root.
   - User correctly held off on pushing.
   - Fix:
     patch scripts/clean-generated-artifacts.sh to remove inspection/validation logs more robustly.
   - Added removal patterns included:
     ./*.log
     ./inspect-*.log
     ./validate-*.log
     ./validate-host-pipeline-*.log
     ./inspect-*test*.log
   - Manually removed:
     inspect-logos-logging-test.log
     inspect-logosloggingtest-1.log
   - Re-ran sanity until artifact scan was clean.
   - Commit/push then proceeded successfully for the workflow hardening changes.

264. Workflow hardening commit completed:
   - Added:
     scripts/build-inspect-stage-example.sh
   - Updated:
     scripts/clean-generated-artifacts.sh
   - Commit message:
     Add example build inspect staging workflow
   - Push completed before the WSL appliance export.
   - This locks in the safer host-side package staging flow:
     build -> inspect -> copy exact artifact -> manifest
   - It reduces risk of transferring the wrong package to the iPhone.

265. V2.27 full WSL appliance export:
   - After workflow hardening commit, user proceeded to a full WSL/toolchain isolated export.
   - Export command pattern:
     wsl --export Ubuntu C:\WSL-Backups\legacy-ios-toolchain-wsl-V2.27.tar
   - Export output:
     operation completed successfully.
   - Export file:
     C:\WSL-Backups\legacy-ios-toolchain-wsl-V2.27.tar
   - Reported size:
     about 5438 MB.
   - SHA256:
     03C9B64C26F59F771DD0DDBCEBCDFEEFB008B8784012240DB977AA8B811B228C
   - Important:
     this tar is private and should not be published.
   - Reason:
     full WSL exports may contain shell history, SSH known hosts, local paths, cached files, package caches, repo remotes, credential residue, device IP traces, and general user-environment state.

266. V2.27 isolated WSL appliance restore validation:
   - Imported appliance under a separate WSL distribution:
     LegacyIOSToolchain-V2.27
   - Restore test ran inside the imported appliance.
   - Validation commands included:
     git status --short
     scripts/verify-toolchain.sh
     scripts/setup-theos-toolchain-links.sh
     scripts/build-ios-machostubs.sh
     scripts/validate-host-pipeline.sh
     scripts/clean-generated-artifacts.sh
     final git status --short.
   - Restored appliance pipeline reached:
     Host pipeline validation complete.
   - It built through the newest validation lane:
     logos-logging-test.
   - Confirmed package artifact during restored validation:
     examples/logos-logging-test/packages/com.bitcrusher32.logosloggingtest_0.0.1-1+debug_iphoneos-arm.deb
   - Reported restored artifact size:
     about 2362 bytes in that run.
   - Cleanup completed:
     Removing generated Theos/example artifacts...
     Removing local validation logs...
     Removing Python caches...
     Generated artifact cleanup complete.
   - Final repo state after cleanup was clean / no visible modified files.
   - Interpretation:
     the private V2.27 appliance is restorable and can reproduce the full host validation pipeline through LogosLoggingTest.

267. V2.27 target matrix planning update:
   - After private appliance restore validation, target matrix planning was added.
   - Purpose:
     document future compatibility lanes without overclaiming support.
   - Added V2.27 planning notes to:
     docs/TARGET_MATRIX.md
   - The notes explicitly state:
     the V2.27 appliance export validates the current host environment as a restorable WSL lane,
     not as a broad device-compatibility claim.
   - Recorded private appliance data:
     legacy-ios-toolchain-wsl-V2.27.tar
     about 5438 MB
     SHA256 03C9B64C26F59F771DD0DDBCEBCDFEEFB008B8784012240DB977AA8B811B228C
   - Restore validation listed:
     toolchain smoke verification
     Theos wrapper setup
     Mach-O stub generation
     full host validation pipeline through logos-logging-test
     generated artifact cleanup.
   - Warning included:
     do not publish the appliance tar.

268. Planned target-lane expansion recorded:
   - Target matrix now includes planning-only lanes:
     Lane A:
       iPhone 4s / iOS 6.1.3 / armv7
       validated current primary lane.
     Lane B:
       iPhone 4 / iOS 5.x-6.x / armv7
       planned.
     Lane C:
       iPad 2 / iPad mini 1 / iOS 6.x / armv7
       planned.
     Lane D:
       iPhone 5 / iOS 6.x-7.x / armv7s
       planned.
     Lane E:
       iPhone 5s / early arm64 / iOS 7.x-8.x / arm64
       research-only.
     Lane F:
       legacy simulator / varies / i386
       optional.
   - Requirement:
     none of these future lanes are supported until validated.
   - Validation requirements documented:
     target device and exact iOS version
     SSH/control path
     package transfer path
     host build
     package inspection
     no-op install/file-placement/uninstall
     controlled respring/runtime tolerance
     post-uninstall clean state
     LogDoc checkpoint
     repo docs update.
   - Hook-capable lane requirements additionally include:
     minimal LogosHookTest runtime lifecycle
     logging-only hook marker validation
     marker cleanup and final clean state.

269. V2.28 milestone meaning:
   - V2.27 was runtime observability on the real iPhone.
   - V2.28 locks that success into:
     a safer host-side workflow script,
     a clean artifact policy,
     a private restorable WSL appliance,
     a restored-appliance host validation,
     and a planning-only target matrix.
   - Current state:
     public Git repo contains reproducible scripts/docs/examples.
     private WSL appliance contains a known-good working host environment.
     device lane A remains the only fully validated device/runtime lane.
   - The project now has both:
     a Git recipe
     and a private frozen operational appliance.

270. Next scope requested: public-accessible container-adjacent export:
   - User wants a real sanitized public-accessible container-adjacent export of the toolchain in a working environment.
   - Important distinction:
     the full WSL appliance export is working but private.
     the public artifact must be sanitized and should not be a raw export of the user's live environment.
   - Recommended direction:
     create a minimal public rootfs/appliance build recipe or sanitizable WSL distribution,
     not a dump of the personal Ubuntu environment.
   - Public artifact should include:
     repo checkout
     built toolchain or reproducible build scripts
     Theos wrapper setup
     Mach-O stub generation
     validation examples
     validation scripts
     no private shell history
     no SSH keys
     no tokens
     no device IPs/passwords
     no private package cache or personal home residue.
   - Candidate names:
     LegacyIOSToolchain-Public-V2.28
     legacy-ios-toolchain-public-V2.28.tar
   - Recommended approach:
     create a fresh minimal WSL Ubuntu import or clean rootfs,
     install only required packages,
     clone public repo,
     run toolchain build/install,
     run validation,
     scrub histories/caches,
     export sanitized tar,
     import it again as a public-restore validation test before release.

271. Updated immediate roadmap after V2.28:
   - Step 1:
     create a sanitized public appliance build process.
   - Step 2:
     build public appliance from clean base or intentionally scrubbed minimal environment.
   - Step 3:
     validate public appliance import in a separate WSL distro.
   - Step 4:
     document public artifact contents and limitations.
   - Step 5:
     publish only if inspection shows no private residues.
   - Step 6:
     then continue target matrix research/expansion planning.
   - Avoid:
     publishing the private V2.27 appliance tar,
     publishing personal home directories,
     publishing SSH keys/configs/known_hosts,
     publishing shell history,
     publishing device passwords or IP-specific docs,
     publishing cached credentials,
     claiming broad device support from host-only appliance validation.

Breakpoint note:
   - V2.28 captures workflow hardening, private WSL export/restore validation, and target matrix planning.
   - The next major task is producing a sanitized, public-safe, container-adjacent appliance/export from a clean build process.


272. Public appliance finalization branch:
   - After V2.28, the next major task was creating and publishing a sanitized public-accessible container-adjacent export.
   - Important boundary:
     public artifact must not be the private V2.27 full WSL export.
   - Public artifact scope:
     toolchain-only sanitized WSL/rootfs-style appliance.
   - Explicitly excluded:
     Apple iPhoneOS SDKs
     private WSL user environment
     SSH keys
     shell history
     device credentials
     private backups
     private V2.27 appliance contents
     device IP/password traces.
   - Reason for excluding Apple SDKs:
     avoid redistributing licensed Apple SDK payloads.
   - Public artifact goal:
     preserve the rebuilt legacy ARMv7 iOS toolchain and smoke-testable validation repo,
     while leaving Theos/iPhoneOS SDK hydration to users with their own legally obtained SDKs.

273. Public build input snapshot created:
   - Source was exported from the Git repo using git archive rather than raw filesystem copy.
   - Purpose:
     avoid including .git metadata,
     remotes,
     credentials,
     local branches,
     generated logs,
     build artifacts,
     or private working-tree residue.
   - Source snapshot:
     legacy-ios-toolchain-wsl-source-V2.28.tar
   - Location:
     C:\WSL-Backups\public-build-inputs\
   - This became the clean repo payload for the public appliance build.

274. Clean Ubuntu rootfs creation:
   - Used debootstrap to create a clean Ubuntu Noble minbase rootfs.
   - Initial dependency install hit a small package-source issue:
     Package texinfo is not available.
   - Cause:
     clean minbase rootfs initially only had a limited apt source set.
   - Fix:
     add apt sources:
       noble main universe
       noble-updates main universe
       noble-security main universe
   - After enabling universe, dependencies installed successfully.
   - This confirmed the public appliance could be built from a clean minimal base instead of private WSL state.

275. Public build distro:
   - Imported the clean rootfs into WSL as:
     LegacyIOSToolchain-PublicBuild
   - Build occurred as root inside the clean WSL distro.
   - Repo source unpacked under:
     /opt/legacy-ios-toolchain-wsl
   - Build/verification flow:
     install minimal build dependencies
     unpack repo source snapshot
     run repo dependency installer as needed
     run scripts/build-toolchain.sh
     run scripts/verify-toolchain.sh
   - Public build reached:
     Verification complete.
   - This validated:
     /usr/bin/arm-apple-darwin-ar
     /usr/bin/arm-apple-darwin-ld
     /usr/bin/arm-apple-darwin-as
     /usr/bin/ldid
     ARMv7 Mach-O object smoke test
     ARMv7 relocatable Mach-O linker smoke test
     archive creation smoke test.

276. Public appliance metadata added:
   - Added:
     /PUBLIC_APPLIANCE_README.txt
     /PUBLIC_APPLIANCE_MANIFEST.txt
   - README stated:
     Legacy iOS ARMv7 Toolchain Public Appliance - V2.28
   - Public scope:
     sanitized public WSL/rootfs-style appliance containing a rebuilt legacy iOS ARMv7 toolchain and validation repo source snapshot.
   - Validated:
     arm-apple-darwin assembler
     arm-apple-darwin relocatable linker
     arm-apple-darwin archive tool
     ldid presence
     repo verify-toolchain.sh smoke test.
   - Not included:
     Apple iPhoneOS SDKs
     private WSL user environment
     SSH keys
     shell history
     device credentials
     private device backups
     private V2.27 appliance contents.
   - Not validated:
     Theos package pipeline
     iPhoneOS SDK header/framework builds
     MobileSubstrate runtime tests
     device install/respring tests.
   - Hydration note:
     users must provide their own legally obtained SDK and configure Theos separately for full package validation.

277. Public appliance sanitization issue found:
   - During public-build sanitization, private-string scan found active documentation references:
     docs/DEVICE_TRANSFER_WORKFLOW.md:
       ▓▓
       literal pscp commands with the device IP
       placeholder examples involving ▓▓
     docs/APPLIANCE_MANIFEST.md:
       ▓▓ hostname in kernel line
     docs/DEVICE_INSTALL_SAFETY_PLAN.md:
       redacted credential string `▓▓`
   - User correctly stopped before export.
   - Interpretation:
     the repo source snapshot itself still contained device/workstation-specific operational documentation.
   - Fix:
     sanitize active docs inside the public appliance:
       replace ▓▓ and variants with <IPHONE_IP>
       redact kernel hostname as <HOSTNAME>
       replace literal credential wording with generic credential wording.
   - git.bitcrusher32.win references were intentionally left acceptable by user decision.

278. Public appliance private-string scan after sanitization:
   - After redaction, private-string scan was rerun.
   - High-risk scan terms included:
     ▓▓
     ▓▓
     ▓▓
     ▓▓
     known_hosts
     BEGIN OPENSSH
     PRIVATE KEY
   - The remaining git.bitcrusher32.win references were considered acceptable public repo/domain references.
   - Final verification was rerun:
     /opt/legacy-ios-toolchain-wsl/scripts/verify-toolchain.sh
   - Result:
     Verification complete.
   - Public appliance was then acceptable for export.

279. Public appliance export and reimport:
   - Public export file:
     C:\WSL-Public-Exports\legacy-ios-toolchain-public-toolchain-V2.28.tar
   - Sidecar files:
     C:\WSL-Public-Exports\legacy-ios-toolchain-public-toolchain-V2.28.sha256.txt
     C:\WSL-Public-Exports\legacy-ios-toolchain-public-toolchain-V2.28.manifest.txt
   - Exported tar size:
     1,581,916,160 bytes.
   - Public-check import succeeded.
   - Public-check validation:
     cat /PUBLIC_APPLIANCE_README.txt
     cat /PUBLIC_APPLIANCE_MANIFEST.txt
     cd /opt/legacy-ios-toolchain-wsl
     ./scripts/verify-toolchain.sh
   - verify-toolchain output:
     checked installed tools
     created ARMv7 asm smoke test
     assembled and linked relocatable Mach-O
     created archive
     ended with Verification complete.
   - This confirms the public tar is independently importable and smoke-testable.

280. Public appliance release upload problem:
   - User attempted to upload the 1.58 GB tar as a Gitea release asset.
   - Browser upload/network save failed.
   - Physical USB transfer to the Gitea machine was chosen.
   - User had SSH access to the Gitea server:
     BastionPlex, Debian 13.
   - Files were staged under:
     /srv/gitea-release-staging/legacy-ios-toolchain/V2.28/
   - Gitea API release asset upload failed for the tar with:
     413 Payload Too Large.
   - Interpretation:
     Gitea release attachment size limit was too low for the appliance tar.
   - Decision:
     do not force the tar into Git history,
     do not commit it to the repo,
     use static hosting fallback for the large tar.

281. Static hosting fallback created:
   - Server-side static directory created:
     /var/www/downloads/legacy-ios-toolchain/V2.28/
   - Public tar copied there:
     legacy-ios-toolchain-public-toolchain-V2.28.tar
   - Initial issue:
     only the .tar was present in the static directory;
     .sha256.txt and .manifest.txt were missing.
   - Fix:
     generate sidecar files directly from the tar on the server:
       sha256sum legacy-ios-toolchain-public-toolchain-V2.28.tar > legacy-ios-toolchain-public-toolchain-V2.28.sha256.txt
       manifest file with filename, sha256, size_bytes, scope, validation, and not_included metadata.
   - Checksum verified successfully:
     legacy-ios-toolchain-public-toolchain-V2.28.tar: OK
   - Sidecars were mirrored back to release staging.

282. Nginx static path issue:
   - First public URL test:
     https://git.bitcrusher32.win/downloads/legacy-ios-toolchain/V2.28/legacy-ios-toolchain-public-toolchain-V2.28.tar
   - Result:
     HTTP/2 404.
   - Headers showed the request reached Gitea rather than static Nginx:
     set-cookie i_like_gitea
     Gitea-style 404 behavior.
   - Diagnosis:
     Nginx was proxying /downloads/ through to Gitea.
   - Fix:
     add Nginx location block for /downloads/ before the generic proxy-to-Gitea location:
       location /downloads/ {
           alias /var/www/downloads/;
           autoindex off;
           types {
               application/x-tar tar;
               text/plain txt;
           }
           default_type application/octet-stream;
           add_header X-Content-Type-Options nosniff always;
           add_header Content-Disposition "attachment";
       }
   - Nginx tested/reloaded.
   - After fix:
     static download path worked.

283. Public release published:
   - Release published for:
     V2.28 Public Toolchain Appliance.
   - Large tar served via static Nginx path instead of Gitea release attachment.
   - Small sidecar assets and/or release notes provide integrity metadata.
   - Release notes should include:
     static tar URL
     SHA256 checksum
     manifest information
     scope: toolchain-only
     exclusions: no Apple SDKs, no private WSL environment, no secrets
     validation: imported and verify-toolchain.sh passed.
   - This is a major public-access milestone:
     the project now has a public importable appliance artifact, not just a private WSL backup and Git recipe.

284. Repo documentation for public appliance:
   - Added:
     docs/PUBLIC_APPLIANCE.md
   - Documented:
     artifact filename
     public scope
     validation status
     exclusions
     import example
     integrity files
     public artifact boundary
     hydration path for Apple SDKs/Theos.
   - Added distribution fallback note:
     if Gitea release upload fails with 413 Payload Too Large,
     host the .tar as a static file and attach only .sha256.txt and .manifest.txt to the release.
   - Explicit warning:
     do not commit the tar to Git.
   - This doc keeps the repo aligned with the release reality.

285. V2.29 milestone significance:
   - V2.27:
     real device hook-body execution validated.
   - V2.28:
     workflow hardened, private appliance validated, target planning documented.
   - V2.29:
     sanitized public toolchain appliance built, scrubbed, import-tested, hosted, and published.
   - The project now has three preservation layers:
     1. Git recipe:
        reproducible source/scripts/docs/examples.
     2. Private full WSL appliance:
        known-good operational environment with full local Theos/SDK state.
     3. Public sanitized toolchain appliance:
        toolchain-only, importable, smoke-tested, no Apple SDKs, no private WSL residue.
   - This completes the first public container-adjacent release milestone.

286. Updated current state after V2.29:
   - Public Git repo:
     contains reproducible scripts/docs/examples and public appliance documentation.
   - Private V2.27 appliance:
     full known-good environment, not published.
   - Public V2.28/V2.29 appliance:
     static-hosted large tar, sidecar checksum/manifest, public release notes.
   - Public appliance validation:
     imported and verify-toolchain.sh passed.
   - Theos/iPhoneOS SDK validation:
     intentionally not included in public appliance.
   - Device runtime validation:
     remains documented from private/local validated Lane A, not part of public appliance.
   - Gitea limitation:
     large tar could not be attached due to 413; static hosting solved distribution.

287. Things to avoid after V2.29:
   - Do not commit appliance tar files to Git.
   - Do not publish private V2.27 full WSL export.
   - Do not add Apple SDKs to public appliance exports.
   - Do not imply public appliance validates Theos/iPhoneOS package builds.
   - Do not remove checksums/manifests from release distribution.
   - Do not leave static files unverified after server changes.
   - Do not overclaim support for non-Lane-A devices.
   - Do not forget that the public appliance is toolchain-only.

288. Recommended next goals after V2.29:
   - Short-term:
     update README to prominently link docs/PUBLIC_APPLIANCE.md and the release.
     verify static tar URL from an external network/browser.
     optionally add a small downloads index page or checksum landing page.
   - Medium-term:
     add a public hydration guide:
       how to import appliance,
       how to add user-provided Theos/SDK,
       how to run host validation where legally supplied SDKs exist.
   - Toolchain-side:
     begin target matrix research without support claims.
   - Device-side:
     only continue with narrow, reversible edge cases if needed.
   - Release hygiene:
     create a V2.29 LogDoc checkpoint and keep release metadata in repo docs.

Breakpoint note:
   - V2.29 marks the first public sanitized container-adjacent release of the recovered legacy iOS ARMv7 toolchain environment.
   - It is a public toolchain appliance, not a full private development appliance.
   - The next branch should be public docs polish and hydration guide, then target matrix research.

