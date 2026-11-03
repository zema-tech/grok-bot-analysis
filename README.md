# grok-bot 0.72.0 — package archive & analysis

Archival copy and static analysis of the Debian package `grok-bot_0.72.0_amd64.deb`.

The original 106 MB archive is stored **split into 40 MiB parts** because GitHub rejects
files larger than 100 MiB **in the git tree**. Reassembling the parts reproduces the original
file byte-for-byte. For a single-file download of the full `.deb`, attach it to a
**[GitHub Release](https://github.com/zema-tech/grok-bot-analysis/releases)** (up to 2 GiB per
asset, no bandwidth cap).

| Property | Value |
| --- | --- |
| File | `grok-bot_0.72.0_amd64.deb` |
| Size | 106,074,508 bytes |
| SHA-256 | `f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd` |
| Package | `grok-bot` 0.72.0, `amd64` |
| Maintainer / Vendor | `SpaceXAI <hi@cursor.com>` |
| Homepage | <https://cursor.com> |
| License | Application: `unknown` — the `control` field says `unknown` and the app manifest has no `license` key. Only Electron/Chromium licenses are bundled (`LICENSE.electron.txt`, `LICENSES.chromium.html`), and they cover the runtime, not this application. |

This repository is **private**: the payload is proprietary, and nothing here grants
redistribution rights.

## Get the full `.deb`

**Preferred** — from a Release asset (after you upload it once):

```bash
./tools/download-deb.sh
```

This tries:

`https://github.com/zema-tech/grok-bot-analysis/releases/download/v0.72.0/grok-bot_0.72.0_amd64.deb`

and verifies SHA-256. If the asset is missing, it falls back to reassembling `parts/`.

**Always available** — rebuild from parts in the repo:

```bash
./tools/reassemble.sh
```

### Publish the Release asset (one-time)

```bash
./tools/reassemble.sh
gh release create v0.72.0 grok-bot_0.72.0_amd64.deb \
  --title "grok-bot 0.72.0 deb" \
  --notes "Full package; SHA-256 f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd"
```

Or: GitHub → Releases → Draft a new release → tag `v0.72.0` → attach the `.deb`.

Why not commit the `.deb` into `main`? GitHub **blocks** any blob &gt; 100 MiB in a push.
Git LFS works up to 2 GB/file but burns free storage/bandwidth quotas; Releases do not.

## Reassemble / split (parts workflow)

```bash
./tools/reassemble.sh
# or manually:
cat parts/grok-bot_0.72.0_amd64.deb.part-* > grok-bot_0.72.0_amd64.deb
sha256sum grok-bot_0.72.0_amd64.deb   # must equal f79aff93…
```

```bash
./tools/split.sh path/to/grok-bot_0.72.0_amd64.deb
```

## Run on a cloud desktop (E2B / Ubuntu GUI)

```bash
./tools/download-deb.sh   # or reassemble.sh
chmod +x tools/run-on-e2b-desktop.sh
./tools/run-on-e2b-desktop.sh
```

Background: `HEADLESS_LAUNCH=1 ./tools/run-on-e2b-desktop.sh`  
See [STATUS.md](STATUS.md).

## Verify this archive

```bash
cd parts && sha256sum -c SHA256SUMS && cd ..
sha256sum -c hashes.sha256 --quiet
./tools/reassemble.sh   # or download-deb.sh
```

## Layout

```
files/          asar-manifest, package.json, desktop entry, apparmor
metadata/       Debian control, scripts, md5sums
parts/          .deb split into ≤40 MiB chunks + SHA256SUMS
tools/
  split.sh
  reassemble.sh
  download-deb.sh         # Release asset, else parts/
  run-on-e2b-desktop.sh   # extract + launch on cloud Ubuntu desktop
hashes.sha256
STATUS.md
```

## What is not in the git tree

- The reassembled `.deb` (use Release asset or `./tools/reassemble.sh`)
- The extracted Electron tree (~351 MB); only manifests under `files/` / `metadata/`

See [ANALYSIS.md](ANALYSIS.md) for payload structure, native modules, and vendor-identity notes.
