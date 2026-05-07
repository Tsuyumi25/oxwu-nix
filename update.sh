#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

declare -A URLS=(
  [x86_64]="https://eew.earthquake.tw/releases/linux/x64/oxwu-linux-x86_64.AppImage"
  [aarch64]="https://eew.earthquake.tw/releases/linux/arm64/oxwu-linux-arm64.AppImage"
  [armv7l]="https://eew.earthquake.tw/releases/linux/armv7l/oxwu-linux-armv7l.AppImage"
)

extract_version() {
  local appimage="$1"
  local tmpdir
  tmpdir=$(mktemp -d)
  trap "rm -rf '$tmpdir'" RETURN

  python3 "$SCRIPT_DIR/extract_version.py" "$appimage" "$tmpdir/squashfs"

  nix-shell -p squashfsTools jq --run "
    unsquashfs -d '$tmpdir/root' '$tmpdir/squashfs' resources/app/package.json >/dev/null 2>&1
    jq -r .version '$tmpdir/root/resources/app/package.json'
  "
}

TMPFILE=""
cleanup() { if [ -n "$TMPFILE" ]; then rm -f "$TMPFILE"; fi; }
trap cleanup EXIT

CHANGED=false
NEW_VERSION=""

for ARCH in "${!URLS[@]}"; do
  URL="${URLS[$ARCH]}"
  ETAG_FILE="$SCRIPT_DIR/etag.$ARCH"

  NEW_ETAG=$(curl -fIs "$URL" | grep -i '^etag:' | sed 's/^[Ee][Tt][Aa][Gg]:[[:space:]]*//' | tr -d '\r\n')
  OLD_ETAG=$(cat "$ETAG_FILE" 2>/dev/null || echo "")

  if [ "$NEW_ETAG" = "$OLD_ETAG" ]; then
    echo "$ARCH: no update"
    continue
  fi

  echo "$ARCH: update detected, downloading..."
  TMPFILE=$(mktemp /tmp/oxwu-XXXXXX.AppImage)
  curl -fL -o "$TMPFILE" "$URL"

  HASH=$(nix hash file "$TMPFILE")

  if [ -z "$NEW_VERSION" ]; then
    NEW_VERSION=$(extract_version "$TMPFILE")
    [ -n "$NEW_VERSION" ] || { echo "ERROR: could not extract version from $ARCH AppImage"; exit 1; }
    echo "version: $NEW_VERSION"
  fi

  grep -q "# $ARCH" "$SCRIPT_DIR/package.nix" || { echo "ERROR: anchor '# $ARCH' not found in package.nix"; exit 1; }
  sed -i "s|hash = \"sha256-[^\"]*\"; # $ARCH|hash = \"$HASH\"; # $ARCH|" "$SCRIPT_DIR/package.nix"
  echo "$NEW_ETAG" > "$ETAG_FILE"

  rm -f "$TMPFILE"; TMPFILE=""
  CHANGED=true
  echo "$ARCH: updated to $HASH"
done

if [ "$CHANGED" = true ]; then
  sed -i "s|version = \"[^\"]*\"|version = \"$NEW_VERSION\"|" "$SCRIPT_DIR/package.nix"
fi

echo "Done."
