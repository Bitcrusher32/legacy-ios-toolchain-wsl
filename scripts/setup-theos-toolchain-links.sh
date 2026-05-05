#!/usr/bin/env bash
set -euo pipefail

THEOS_PATH="${THEOS:-$HOME/theos}"
BIN="$THEOS_PATH/toolchain/linux/iphone/bin"

mkdir -p "$BIN"

ln -sf /usr/bin/arm-apple-darwin-ar "$BIN/ar"
ln -sf /usr/bin/arm-apple-darwin-ld "$BIN/ld"
ln -sf /usr/bin/arm-apple-darwin-strip "$BIN/strip"
ln -sf /usr/bin/arm-apple-darwin-ranlib "$BIN/ranlib"

cat > "$BIN/clang" <<'WRAP'
#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  -dumpversion)
    echo "18.1.3"
    exit 0
    ;;
esac

args=()
for arg in "$@"; do
  case "$arg" in
    -fmodules|-fcxx-modules|-fmodules-validate-once-per-build-session)
      ;;
    -fmodule-name=*|-fbuild-session-file=*|-fmodules-prune-after=*|-fmodules-prune-interval=*)
      ;;
    *)
      args+=("$arg")
      ;;
  esac
done

exec /usr/bin/clang -B"$(dirname "$0")" "${args[@]}"
WRAP

cat > "$BIN/clang++" <<'WRAP'
#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
  -dumpversion)
    echo "18.1.3"
    exit 0
    ;;
esac

args=()
for arg in "$@"; do
  case "$arg" in
    -fmodules|-fcxx-modules|-fmodules-validate-once-per-build-session)
      ;;
    -fmodule-name=*|-fbuild-session-file=*|-fmodules-prune-after=*|-fmodules-prune-interval=*)
      ;;
    *)
      args+=("$arg")
      ;;
  esac
done

exec /usr/bin/clang++ -B"$(dirname "$0")" -L"$HOME/ios-sdk-machostubs/iPhoneOS9.3/usr/lib" "${args[@]}"
WRAP

cat > "$BIN/ldid" <<'WRAP'
#!/usr/bin/env bash
unset CODESIGN_ALLOCATE
exec /usr/bin/ldid "$@"
WRAP

cat > "$BIN/codesign_allocate" <<'WRAP'
#!/usr/bin/env bash
# Shim for Linux ldid/Theos compatibility.
# Real /usr/bin/ldid works when CODESIGN_ALLOCATE is unset.
exit 0
WRAP

chmod +x "$BIN/clang" "$BIN/clang++" "$BIN/ldid" "$BIN/codesign_allocate"

echo "Theos iPhone toolchain wrappers installed at: $BIN"
