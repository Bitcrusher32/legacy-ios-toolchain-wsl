#!/usr/bin/env bash
set -euo pipefail

sudo apt update

sudo apt install -y \
  build-essential \
  clang \
  llvm \
  llvm-dev \
  lld \
  autoconf \
  automake \
  libtool \
  pkg-config \
  git \
  gawk \
  bison \
  flex \
  texinfo \
  libssl-dev \
  libxml2-dev \
  zlib1g-dev \
  libpng-dev \
  uuid-dev \
  liblzma-dev \
  python3 \
  file
