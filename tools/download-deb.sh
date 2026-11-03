#!/usr/bin/env bash
# Obtain grok-bot_0.72.0_amd64.deb either from a GitHub Release asset or by reassembling parts/.
# Prefer Releases: Git rejects files >100 MiB in the repository tree; release assets allow up to 2 GiB.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

OUT="grok-bot_0.72.0_amd64.deb"
EXPECTED="f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd"
# Tag/name used when the full .deb is attached to a Release (upload once via GitHub UI or gh).
TAG="${RELEASE_TAG:-v0.72.0}"
OWNER="${GITHUB_OWNER:-zema-tech}"
REPO="${GITHUB_REPO:-grok-bot-analysis}"
ASSET_URL="https://github.com/${OWNER}/${REPO}/releases/download/${TAG}/${OUT}"

verify() {
  local actual
  actual=$(sha256sum "$OUT" | awk '{print $1}')
  if [[ "$actual" != "$EXPECTED" ]]; then
    echo "SHA-256 mismatch for $OUT" >&2
    echo "  expected: $EXPECTED" >&2
    echo "  got:      $actual" >&2
    return 1
  fi
  echo "OK: $OUT ($(stat -c%s "$OUT" 2>/dev/null || stat -f%z "$OUT") bytes) sha256=$actual"
}

if [[ -f "$OUT" ]]; then
  if verify; then
    exit 0
  fi
  echo "Existing $OUT is corrupt; removing and retrying" >&2
  rm -f "$OUT"
fi

echo "==> Try download from GitHub Release ${TAG}"
if command -v curl >/dev/null 2>&1; then
  if curl -fL --retry 3 --retry-delay 2 -o "$OUT" "$ASSET_URL"; then
    verify
    exit 0
  fi
elif command -v wget >/dev/null 2>&1; then
  if wget -O "$OUT" "$ASSET_URL"; then
    verify
    exit 0
  fi
fi

echo "Release asset not available (or download failed). Falling back to parts/ reassemble."
bash tools/reassemble.sh
verify
