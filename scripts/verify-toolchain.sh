#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Checking installed tools..."
which arm-apple-darwin-ar
which arm-apple-darwin-ld
which arm-apple-darwin-as
which ldid

echo "[2/4] Creating ARMv7 asm smoke test..."
TEST_DIR="${HOME}/ios-toolchain-tests/asm"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

cat > test.s <<'ASM'
.text
.align 2
.globl _main
_main:
    mov r0, #0
    bx lr
ASM

echo "[3/4] Assembling and linking relocatable Mach-O..."
arm-apple-darwin-as -arch armv7 -o test.o test.s
file test.o

arm-apple-darwin-ld -arch armv7 -r -o test_reloc.o test.o
file test_reloc.o

echo "[4/4] Creating archive..."
arm-apple-darwin-ar rcs libtest.a test.o
file libtest.a
arm-apple-darwin-ar t libtest.a

echo "Verification complete."
