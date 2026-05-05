#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 path/to/package.deb" >&2
  exit 2
fi

DEB="$1"

if [ ! -f "$DEB" ]; then
  echo "Package not found: $DEB" >&2
  exit 1
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "=== package ==="
realpath "$DEB"
ls -lh "$DEB"
file "$DEB"

echo
echo "=== dpkg-deb info ==="
dpkg-deb -I "$DEB"

echo
echo "=== package file list ==="
dpkg-deb -c "$DEB"

echo
echo "=== extracted control ==="
dpkg-deb -e "$DEB" "$TMP/control"
find "$TMP/control" -maxdepth 2 -type f -print -exec sed -n '1,220p' {} \;

echo
echo "=== extracted data tree ==="
dpkg-deb -x "$DEB" "$TMP/data"
find "$TMP/data" -maxdepth 8 \( -type f -o -type l \) | sort

echo
echo "=== DynamicLibraries payload ==="
find "$TMP/data/Library/MobileSubstrate/DynamicLibraries" -maxdepth 1 \( -type f -o -type l \) -print 2>/dev/null | sort || true

echo
echo "=== Mach-O details for dylibs ==="
while IFS= read -r dylib; do
  echo
  echo "--- $dylib ---"
  file "$dylib"
  arm-apple-darwin-otool -L "$dylib" 2>/dev/null || true
  echo "Undefined symbols:"
  arm-apple-darwin-nm -u "$dylib" 2>/dev/null | sort || true
done < <(find "$TMP/data" -type f -name '*.dylib' | sort)

echo
echo "Inspection complete."
