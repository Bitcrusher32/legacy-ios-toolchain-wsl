#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Tidal-Loop/linux-ios-toolchain.git"
WORKDIR="${HOME}/linux-ios-toolchain"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

echo "[1/6] Cloning base toolchain if needed..."
if [ ! -d "$WORKDIR/.git" ]; then
  git clone "$REPO_URL" "$WORKDIR"
else
  echo "Existing repo found at $WORKDIR"
fi

cd "$WORKDIR"

echo "[2/6] Initializing submodules..."
git submodule update --init --recursive

echo "[3/6] Applying Linux/WSL patches..."
"${REPO_ROOT}/scripts/apply-linux-wsl-patches.py" "$WORKDIR"

echo "[4/6] Configuring target..."
./configure arm-apple-darwin

echo "[5/6] Building..."
CFLAGS="-fcommon" CXXFLAGS="-fcommon" make 2>&1 | tee build.log

echo "[6/6] Installing..."
sudo make install 2>&1 | tee install-sudo.log

echo "Build/install complete. Run verify-toolchain.sh from this repo next."
