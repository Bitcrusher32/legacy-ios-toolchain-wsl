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

# CoreFoundation framework stub.
CF_FRAMEWORK_DIR="$STUB_ROOT/System/Library/Frameworks/CoreFoundation.framework"
mkdir -p "$CF_FRAMEWORK_DIR"

cat > "$CF_FRAMEWORK_DIR/CoreFoundation_stub.s" <<'ASM'
.data
.align 2
.globl _kCFAllocatorDefault
_kCFAllocatorDefault:
    .long 0

.text
.align 2
.globl _CFStringCreateWithCString
_CFStringCreateWithCString:
    mov r0, #0
    bx lr
ASM

arm-apple-darwin-as -arch armv7 -o "$CF_FRAMEWORK_DIR/CoreFoundation_stub.o" "$CF_FRAMEWORK_DIR/CoreFoundation_stub.s"

arm-apple-darwin-ld \
  -arch armv7 \
  -dylib \
  -install_name /System/Library/Frameworks/CoreFoundation.framework/CoreFoundation \
  -o "$CF_FRAMEWORK_DIR/CoreFoundation" \
  "$CF_FRAMEWORK_DIR/CoreFoundation_stub.o"

if [ -n "${THEOS:-}" ] && [ -d "$THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/CoreFoundation.framework/Headers" ]; then
  ln -sfn \
    "$THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/CoreFoundation.framework/Headers" \
    "$CF_FRAMEWORK_DIR/Headers"
else
  echo "Warning: THEOS not set or CoreFoundation SDK headers not found; Headers symlink not created."
fi

file "$CF_FRAMEWORK_DIR/CoreFoundation"
arm-apple-darwin-nm -g "$CF_FRAMEWORK_DIR/CoreFoundation" | grep -E 'CFStringCreateWithCString|kCFAllocatorDefault' || true

# Foundation framework stub.
FOUNDATION_FRAMEWORK_DIR="$STUB_ROOT/System/Library/Frameworks/Foundation.framework"
mkdir -p "$FOUNDATION_FRAMEWORK_DIR"

cat > "$FOUNDATION_FRAMEWORK_DIR/Foundation_stub.s" <<'ASM'
.data
.align 2
.globl ___CFConstantStringClassReference
___CFConstantStringClassReference:
    .long 0

.text
.align 2
.globl _NSClassFromString
_NSClassFromString:
    mov r0, #0
    bx lr
ASM

arm-apple-darwin-as -arch armv7 -o "$FOUNDATION_FRAMEWORK_DIR/Foundation_stub.o" "$FOUNDATION_FRAMEWORK_DIR/Foundation_stub.s"

arm-apple-darwin-ld \
  -arch armv7 \
  -dylib \
  -install_name /System/Library/Frameworks/Foundation.framework/Foundation \
  -o "$FOUNDATION_FRAMEWORK_DIR/Foundation" \
  "$FOUNDATION_FRAMEWORK_DIR/Foundation_stub.o"

if [ -n "${THEOS:-}" ] && [ -d "$THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/Foundation.framework/Headers" ]; then
  ln -sfn \
    "$THEOS/sdks/iPhoneOS9.3.sdk/System/Library/Frameworks/Foundation.framework/Headers" \
    "$FOUNDATION_FRAMEWORK_DIR/Headers"
else
  echo "Warning: THEOS not set or Foundation SDK headers not found; Headers symlink not created."
fi

file "$FOUNDATION_FRAMEWORK_DIR/Foundation"
arm-apple-darwin-nm -g "$FOUNDATION_FRAMEWORK_DIR/Foundation" | grep -E 'NSClassFromString|CFConstantStringClassReference' || true

