#!/usr/bin/env python3
from pathlib import Path
import sys

if len(sys.argv) != 2:
    raise SystemExit("usage: apply-linux-wsl-patches.py /path/to/linux-ios-toolchain")

ROOT = Path(sys.argv[1]).expanduser().resolve()
LD64 = ROOT / "build/cctools/cctools/ld64"

def replace_exact(path: Path, old: str, new: str, label: str) -> None:
    text = path.read_text()
    if new in text and old not in text:
        print(f"[already patched] {label}: {path}")
        return
    if old not in text:
        raise SystemExit(f"[missing pattern] {label}: {path}")
    path.write_text(text.replace(old, new))
    print(f"[patched] {label}: {path}")

def remove_exact(path: Path, old: str, label: str) -> None:
    text = path.read_text()
    if old not in text:
        print(f"[already removed] {label}: {path}")
        return
    path.write_text(text.replace(old, ""))
    print(f"[removed] {label}: {path}")

def main() -> None:
    if not LD64.exists():
        raise SystemExit(f"ld64 tree not found: {LD64}")

    input_files = LD64 / "src/ld/InputFiles.cpp"
    input_header = LD64 / "src/ld/InputFiles.h"
    ld_cpp = LD64 / "src/ld/ld.cpp"
    resolver_h = LD64 / "src/ld/Resolver.h"
    options_cpp = LD64 / "src/ld/Options.cpp"
    memutils_h = LD64 / "src/ld/code-sign-blobs/memutils.h"
    macho_cpp = LD64 / "src/ld/parsers/macho_relocatable_file.cpp"

    for path in [input_files, input_header, ld_cpp, resolver_h]:
        remove_exact(path, "#include <sys/sysctl.h>\n", "remove sys/sysctl.h")

    replace_exact(
        input_files,
"""		unsigned int ncpus;
		int mib[2];
		size_t len = sizeof(ncpus);
		mib[0] = CTL_HW;
		mib[1] = HW_NCPU;
		if (sysctl(mib, 2, &ncpus, &len, NULL, 0) != 0) {
			ncpus = 1;
		}
""",
"""		long cpuCount = sysconf(_SC_NPROCESSORS_ONLN);
		unsigned int ncpus = (cpuCount > 0) ? (unsigned int)cpuCount : 1;
""",
        "InputFiles.cpp sysconf CPU count",
    )

    replace_exact(
        options_cpp,
"""			int mib[2] = { CTL_KERN, KERN_OSRELEASE };
			char kernVersStr[100];
			size_t strlen = sizeof(kernVersStr);
			if ( sysctl(mib, 2, kernVersStr, &strlen, NULL, 0) != -1 ) {
				uint32_t kernVers = parseVersionNumber32(kernVersStr);
				int minor = (kernVers >> 16) - 4;  // kernel major version is 4 ahead of x in 10.x
				fSDKVersion = 0x000A0000 + (minor << 8);
			}
""",
"""			// Linux/WSL host fallback: no BSD sysctl(KERN_OSRELEASE).
			// This path is only for inferring a host Mac SDK version when none is supplied.
			fSDKVersion = 0x000A0800; // 10.8 fallback
""",
        "Options.cpp SDK fallback",
    )

    replace_exact(
        memutils_h,
"""//#include <stddef.h>
#include <security_utilities/utilities.h>
#include <sys/types.h>
""",
"""#include <stddef.h>
#include <sys/types.h>
""",
        "memutils.h Linux headers",
    )

    cfi_repls = {
        "libunwind::CFI_Atom_Info<CFISection<x86_64>::OAS>::CFI_Atom_Info cfiArray[]":
        "libunwind::CFI_Atom_Info<CFISection<x86_64>::OAS> cfiArray[]",

        "libunwind::CFI_Atom_Info<CFISection<x86>::OAS>::CFI_Atom_Info cfiArray[]":
        "libunwind::CFI_Atom_Info<CFISection<x86>::OAS> cfiArray[]",

        "libunwind::CFI_Atom_Info<CFISection<arm>::OAS>::CFI_Atom_Info cfiArray[]":
        "libunwind::CFI_Atom_Info<CFISection<arm>::OAS> cfiArray[]",

        "libunwind::CFI_Atom_Info<CFISection<arm64>::OAS>::CFI_Atom_Info cfiArray[]":
        "libunwind::CFI_Atom_Info<CFISection<arm64>::OAS> cfiArray[]",
    }

    for old, new in cfi_repls.items():
        replace_exact(macho_cpp, old, new, "CFI_Atom_Info template fix")

    print("All Linux/WSL patches applied.")

if __name__ == "__main__":
    main()
