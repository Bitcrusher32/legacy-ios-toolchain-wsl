# Verification

## Installed tools

Run:

    which arm-apple-darwin-ar
    which arm-apple-darwin-ld
    which arm-apple-darwin-as
    which ldid

Expected:

    /usr/bin/arm-apple-darwin-ar
    /usr/bin/arm-apple-darwin-ld
    /usr/bin/arm-apple-darwin-as
    /usr/bin/ldid

## ARMv7 Mach-O smoke test

Run:

    mkdir -p ~/ios-toolchain-tests/asm
    cd ~/ios-toolchain-tests/asm

    cat > test.s <<'ASM'
    .text
    .align 2
    .globl _main
    _main:
        mov r0, #0
        bx lr
    ASM

    arm-apple-darwin-as -arch armv7 -o test.o test.s
    file test.o

    arm-apple-darwin-ld -arch armv7 -r -o test_reloc.o test.o
    file test_reloc.o

    arm-apple-darwin-ar rcs libtest.a test.o
    file libtest.a
    arm-apple-darwin-ar t libtest.a

Expected key outputs:

    test.o: Mach-O armv7 object
    test_reloc.o: Mach-O armv7 object
    libtest.a: current ar archive random library
