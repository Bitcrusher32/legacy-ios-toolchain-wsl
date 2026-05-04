#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Tidal-Loop/linux-ios-toolchain.git"
WORKDIR="${HOME}/linux-ios-toolchain"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "[1/5] Cloning base toolchain if needed..."
if [ ! -d "$WORKDIR/.git" ]; then
  git clone "$REPO_URL" "$WORKDIR"
else
  echo "Existing repo found at $WORKDIR"
fi

cd "$WORKDIR"

echo "[2/4] Initializing submodules..."
git submodule update --init --recursive

echo "[3/4] Applying Linux/WSL patches..."
"${REPO_ROOT}/scripts/apply-linux-wsl-patches.py" "$WORKDIR"

echo "[4/5] Building..."
CFLAGS="-fcommon" CXXFLAGS="-fcommon" make 2>&1 | tee build.log

echo "[5/5] Installing..."
sudo make install 2>&1 | tee install-sudo.log

echo "Build/install complete. Run verify-toolchain.sh from this repo next."
