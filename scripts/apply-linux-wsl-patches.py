#!/usr/bin/env python3
from pathlib import Path
import sys
import re

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
    old_bytes = old.encode("utf-8")
    data = path.read_bytes()
    if old_bytes not in data:
        print(f"[already removed] {label}: {path}")
        return
    path.write_bytes(data.replace(old_bytes, b""))
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
    macosx_deploy_c = ROOT / "build/cctools/cctools/libstuff/macosx_deployment_target.c"

    for path in LD64.rglob("*"):
        if path.is_file() and path.suffix in {".c", ".cc", ".cpp", ".h", ".hpp"}:
            remove_exact(path, "#include <sys/sysctl.h>\n", "remove ld64 sys/sysctl.h")

    remove_exact(macosx_deploy_c, "#include <sys/sysctl.h>\n", "macosx_deployment_target.c remove sys/sysctl.h")

    text = macosx_deploy_c.read_text()
    if "Linux/WSL fallback: this cross-build cannot query Darwin" in text:
        print(f"[already patched] macosx_deployment_target.c default fallback: {macosx_deploy_c}")
    else:
        pattern = re.compile(
            r"""(?ms)^use_default:\n"""
            r""".*?"""
            r"""^\tvalue->name = allocate\(32\);\n"""
            r"""^\tsprintf\(value->name, "10\.%u\.%u", major, minor\);\n"""
            r"""^\tgoto warn_if_bad_user_values;\n"""
        )

        replacement = """use_default:
	/*
	 * Linux/WSL fallback: this cross-build cannot query Darwin's
	 * kern.osrelease via sysctl, so use a deterministic Mac OS X 10.8
	 * default matching the ld64 SDK fallback used elsewhere.
	 */
	value->major = 8;
	value->minor = 0;
	value->name = allocate(strlen("10.8") + 1);
	strcpy(value->name, "10.8");
	goto warn_if_bad_user_values;
"""

        text2, count = pattern.subn(replacement, text, count=1)
        if count != 1:
            raise SystemExit(f"[missing pattern] macosx_deployment_target.c default fallback: {macosx_deploy_c}")
        macosx_deploy_c.write_text(text2)
        print(f"[patched] macosx_deployment_target.c default fallback: {macosx_deploy_c}")

    text = input_files.read_text()
    if "_SC_NPROCESSORS_ONLN" in text:
        print(f"[already patched] InputFiles.cpp sysconf CPU count: {input_files}")
    else:
        pattern = re.compile(
            r"""(?m)^[ \t]*unsigned int ncpus;\n"""
            r"""^[ \t]*int mib\[2\];\n"""
            r"""^[ \t]*size_t len = sizeof\(ncpus\);\n"""
            r"""^[ \t]*mib\[0\] = CTL_HW;\n"""
            r"""^[ \t]*mib\[1\] = HW_NCPU;\n"""
            r"""^[ \t]*if \(sysctl\(mib, 2, &ncpus, &len, NULL, 0\) != 0\) \{\n"""
            r"""^[ \t]*ncpus = 1;\n"""
            r"""^[ \t]*\}\n"""
        )
        replacement = (
            "        long cpuCount = sysconf(_SC_NPROCESSORS_ONLN);\n"
            "        unsigned int ncpus = (cpuCount > 0) ? (unsigned int)cpuCount : 1;\n"
        )
        text2, count = pattern.subn(replacement, text)
        if count != 1:
            raise SystemExit(f"[missing pattern] InputFiles.cpp sysconf CPU count: {input_files}")
        input_files.write_text(text2)
        print(f"[patched] InputFiles.cpp sysconf CPU count: {input_files}")

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

    text = memutils_h.read_text()
    original = text
    text = text.replace("#include <security_utilities/utilities.h>\n", "")
    text = text.replace("//#include <security_utilities/utilities.h>\n", "")
    text = text.replace("//#include <stddef.h>\n", "")
    if "#include <stddef.h>" not in text:
        text = text.replace("#include <sys/types.h>\n", "#include <stddef.h>\n#include <sys/types.h>\n", 1)
    if "#include <cstddef>" not in text:
        text = text.replace("#include <stddef.h>\n", "#include <stddef.h>\n#include <cstddef>\n", 1)
    if "using std::ptrdiff_t;" not in text:
        text = text.replace("#include <sys/types.h>\n", "#include <sys/types.h>\nusing std::ptrdiff_t;\n", 1)
    if text == original:
        print(f"[already patched] memutils.h Linux headers: {memutils_h}")
    else:
        memutils_h.write_text(text)
        print(f"[patched] memutils.h Linux headers: {memutils_h}")

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
