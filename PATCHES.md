# Patch Timeline

Base repo:
https://github.com/Tidal-Loop/linux-ios-toolchain

Validated host:
- WSL Ubuntu 24.04.3 LTS

Validated target context:
- iPhone 4s
- iOS 6.1.3
- ARMv7

## Patches applied

1. Fixed ld64 CFI parser template errors

Changed invalid constructor-style type references:

    CFI_Atom_Info<...>::CFI_Atom_Info

to:

    CFI_Atom_Info<...>

2. Replaced BSD sysctl CPU-count logic

In:

    ld64/src/ld/InputFiles.cpp

Replaced BSD/macOS `sysctl()` CPU detection with:

    sysconf(_SC_NPROCESSORS_ONLN)

3. Removed dead sys/sysctl.h includes

Removed repeated Darwin-only includes across ld64:

    #include <sys/sysctl.h>

4. Replaced Options.cpp Darwin host version detection

Removed use of:

    CTL_KERN
    KERN_OSRELEASE
    sysctl()

Used fallback:

    fSDKVersion = 0x000A0800

5. Fixed code-sign-blobs/memutils.h

Enabled:

    #include <stddef.h>

Removed Apple-only include:

    #include <security_utilities/utilities.h>

## Current validation level

Confirmed:
- toolchain builds
- `sudo make install` installs tools into `/usr/bin`
- assembler emits Mach-O armv7 object
- linker emits Mach-O armv7 relocatable object
- ar creates valid archive

Not yet confirmed:
- full iOS executable linking
- SDK/libSystem path
- Theos tweak build
- .deb packaging
- device install
