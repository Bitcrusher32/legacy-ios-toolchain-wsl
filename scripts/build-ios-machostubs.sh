#!/usr/bin/env bash
set -euo pipefail

STUB_ROOT="${IOS_MACHOSTUBS_ROOT:-$HOME/ios-sdk-machostubs/iPhoneOS9.3}"
LIB_DIR="$STUB_ROOT/usr/lib"

mkdir -p "$LIB_DIR"

cat > "$LIB_DIR/libobjc_stub.s" <<'ASM'
.text
.align 2
.globl _objc_getClass
_objc_getClass:
    bx lr
ASM

arm-apple-darwin-as -arch armv7 -o "$LIB_DIR/libobjc_stub.o" "$LIB_DIR/libobjc_stub.s"

arm-apple-darwin-ld \
  -arch armv7 \
  -dylib \
  -install_name /usr/lib/libobjc.A.dylib \
  -o "$LIB_DIR/libobjc.dylib" \
  "$LIB_DIR/libobjc_stub.o"

cat > "$LIB_DIR/libSystem_stub.s" <<'ASM'
.text
.align 2
.globl dyld_stub_binder
dyld_stub_binder:
    bx lr
ASM

arm-apple-darwin-as -arch armv7 -o "$LIB_DIR/libSystem_stub.o" "$LIB_DIR/libSystem_stub.s"

arm-apple-darwin-ld \
  -arch armv7 \
  -dylib \
  -install_name /usr/lib/libSystem.B.dylib \
  -o "$LIB_DIR/libSystem.dylib" \
  "$LIB_DIR/libSystem_stub.o"

echo "Mach-O stubs generated under: $STUB_ROOT"
file "$LIB_DIR/libobjc.dylib"
file "$LIB_DIR/libSystem.dylib"
arm-apple-darwin-nm -g "$LIB_DIR/libobjc.dylib" | grep objc || true
arm-apple-darwin-nm -g "$LIB_DIR/libSystem.dylib" | grep dyld || true
