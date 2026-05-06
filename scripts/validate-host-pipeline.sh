#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export THEOS="${THEOS:-$HOME/theos}"
export PATH="$THEOS/toolchain/linux/iphone/bin:$PATH"

echo "=== [1/7] Toolchain smoke verification ==="
"$REPO_ROOT/scripts/verify-toolchain.sh"

echo "=== [2/7] Theos wrapper setup ==="
"$REPO_ROOT/scripts/setup-theos-toolchain-links.sh"

echo "=== [3/7] Mach-O SDK stub generation ==="
"$REPO_ROOT/scripts/build-ios-machostubs.sh"

build_example() {
  local name="$1"
  local dir="$REPO_ROOT/examples/$name"

  echo
  echo "=== Building example: $name ==="

  if [ ! -d "$dir" ]; then
    echo "Missing example directory: $dir" >&2
    exit 1
  fi

  cd "$dir"
  make clean
  make package messages=yes

  echo "=== Package artifacts for $name ==="
  if ! find "$dir/packages" -maxdepth 1 -type f -name '*.deb' -print -quit | grep -q .; then
    echo "No .deb package produced for example: $name" >&2
    exit 1
  fi
  find "$dir/packages" -maxdepth 1 -type f -name '*.deb' -ls
}

echo "=== [4/7] No-op tweak ==="
build_example "noop-tweak"

echo "=== [5/7] ObjC runtime test ==="
build_example "objc-runtime-test"

echo "=== [6/7] CoreFoundation / Foundation tests ==="
build_example "corefoundation-test"
build_example "foundation-test"

echo "=== [7/8] Logos hook test ==="
build_example "logos-hook-test"

echo "=== [8/8] Logos logging test ==="
build_example "logos-logging-test"

echo
echo "Host pipeline validation complete."
