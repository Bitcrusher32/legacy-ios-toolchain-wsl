#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "Usage: $0 <example-name>"
  echo
  echo "Examples:"
  find examples -maxdepth 1 -mindepth 1 -type d -printf '  %f\n' | sort
  exit 2
fi

EXAMPLE="$1"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EXAMPLE_DIR="$REPO_ROOT/examples/$EXAMPLE"
WINDOWS_STAGE="/mnt/c/iPhone4sPush"

if [ ! -d "$EXAMPLE_DIR" ]; then
  echo "Example not found: $EXAMPLE_DIR" >&2
  exit 1
fi

if [ ! -f "$EXAMPLE_DIR/Makefile" ]; then
  echo "Example has no Makefile: $EXAMPLE_DIR" >&2
  exit 1
fi

echo "=== repo ==="
echo "$REPO_ROOT"

echo "=== example ==="
echo "$EXAMPLE_DIR"

echo "=== clean generated artifacts first ==="
"$REPO_ROOT/scripts/clean-generated-artifacts.sh"

echo "=== setup Theos wrappers ==="
"$REPO_ROOT/scripts/setup-theos-toolchain-links.sh"

echo "=== rebuild Mach-O stubs ==="
"$REPO_ROOT/scripts/build-ios-machostubs.sh"

echo "=== build package ==="
(
  cd "$EXAMPLE_DIR"
  PATH="$THEOS/toolchain/linux/iphone/bin:$PATH" make clean
  PATH="$THEOS/toolchain/linux/iphone/bin:$PATH" make package messages=yes
)

echo "=== locate package ==="
DEB="$(find "$EXAMPLE_DIR/packages" -type f -name '*.deb' | sort | tail -1)"
if [ -z "${DEB:-}" ] || [ ! -f "$DEB" ]; then
  echo "No package produced under $EXAMPLE_DIR/packages" >&2
  exit 1
fi

echo "DEB=$DEB"

echo "=== inspect package ==="
INSPECT_LOG="$REPO_ROOT/inspect-${EXAMPLE}.log"
"$REPO_ROOT/scripts/inspect-deb-package.sh" "$DEB" 2>&1 | tee "$INSPECT_LOG"

echo "=== stage exact package to Windows bridge ==="
mkdir -p "$WINDOWS_STAGE"
cp "$DEB" "$WINDOWS_STAGE/"

DEB_BASENAME="$(basename "$DEB")"
STAGED="$WINDOWS_STAGE/$DEB_BASENAME"

echo "=== write stage manifest ==="
MANIFEST="$WINDOWS_STAGE/${DEB_BASENAME}.manifest.txt"
{
  echo "example=$EXAMPLE"
  echo "repo=$REPO_ROOT"
  echo "source_deb=$DEB"
  echo "staged_deb=$STAGED"
  echo "staged_at=$(date -Is)"
  echo "sha256=$(sha256sum "$STAGED" | awk '{print $1}')"
  echo "size_bytes=$(stat -c '%s' "$STAGED")"
} > "$MANIFEST"

echo "=== staged package ==="
ls -la "$STAGED"
cat "$MANIFEST"

echo
echo "Next transfer from Windows PowerShell:"
echo "pscp.exe C:\\iPhone4sPush\\$DEB_BASENAME root@<IPHONE_IP>:/var/root/"
echo
echo "Inspection log left at: $INSPECT_LOG"
echo "Delete that log before commit, or run clean-generated-artifacts.sh if updated to remove inspect logs."
