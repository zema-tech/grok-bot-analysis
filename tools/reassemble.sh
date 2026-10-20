#!/usr/bin/env bash
# Reassemble the original .deb from parts/ and verify its SHA-256.
set -euo pipefail
cd "$(dirname "$0")/.."

OUT="grok-bot_0.72.0_amd64.deb"
EXPECTED="f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd"

cat parts/grok-bot_0.72.0_amd64.deb.part-* > "$OUT"
ACTUAL=$(sha256sum "$OUT" | cut -d' ' -f1)

if [ "$ACTUAL" != "$EXPECTED" ]; then
  echo "SHA-256 mismatch: got $ACTUAL" >&2
  exit 1
fi
echo "OK: $OUT ($(stat -c%s "$OUT") bytes) sha256=$ACTUAL"
