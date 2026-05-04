#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/Tidal-Loop/linux-ios-toolchain.git"
WORKDIR="${HOME}/linux-ios-toolchain"

echo "[1/4] Cloning base toolchain if needed..."
if [ ! -d "$WORKDIR/.git" ]; then
  git clone "$REPO_URL" "$WORKDIR"
else
  echo "Existing repo found at $WORKDIR"
fi

cd "$WORKDIR"

echo "[2/4] NOTE: patch application is not automated yet."
echo "Apply documented patches from PATCHES.md before first full build."

echo "[3/4] Building..."
CFLAGS="-fcommon" CXXFLAGS="-fcommon" make 2>&1 | tee build.log

echo "[4/4] Installing..."
sudo make install 2>&1 | tee install-sudo.log

echo "Build/install complete. Run verify-toolchain.sh from this repo next."
