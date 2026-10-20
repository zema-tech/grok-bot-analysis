#!/usr/bin/env bash
# Split a .deb into <=40 MiB parts and regenerate parts/SHA256SUMS.
set -euo pipefail
cd "$(dirname "$0")/.."

SRC="${1:-grok-bot_0.72.0_amd64.deb}"
test -f "$SRC" || { echo "missing $SRC" >&2; exit 1; }

rm -f parts/grok-bot_0.72.0_amd64.deb.part-*
split -b 40M -d -a 2 "$SRC" parts/grok-bot_0.72.0_amd64.deb.part-
( cd parts && sha256sum grok-bot_0.72.0_amd64.deb.part-* > SHA256SUMS )
cat parts/SHA256SUMS
