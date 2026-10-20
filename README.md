# grok-bot 0.72.0 — package archive & analysis

Archival copy and static analysis of the Debian package `grok-bot_0.72.0_amd64.deb`.

The original 106 MB archive is stored **split into 40 MiB parts** because GitHub rejects
files larger than 100 MiB. Reassembling the parts reproduces the original file
byte-for-byte.

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

## Reassemble the package

```bash
./tools/reassemble.sh
```

The script concatenates `parts/grok-bot_0.72.0_amd64.deb.part-*`, writes
`grok-bot_0.72.0_amd64.deb` in the repository root, and fails unless the result matches
the expected SHA-256 and size. Equivalent manual form:

```bash
cat parts/grok-bot_0.72.0_amd64.deb.part-* > grok-bot_0.72.0_amd64.deb
sha256sum grok-bot_0.72.0_amd64.deb   # must equal f79aff93…
```

To recreate the parts from a `.deb`:

```bash
./tools/split.sh path/to/grok-bot_0.72.0_amd64.deb
```

## Verify this archive

Run from the repository root, in this order.

```bash
# 1. Parts match their own checksums (3 files, 40 MiB + 40 MiB + 22,188,428 B)
cd parts && sha256sum -c SHA256SUMS && cd ..

# 2. Every committed artifact matches its recorded digest
sha256sum -c hashes.sha256 --quiet

# 3. Reassembled package matches the source package
./tools/reassemble.sh
```

`hashes.sha256` deliberately omits the `part-*` chunks (they are covered by
`parts/SHA256SUMS`); it covers `files/`, `metadata/`, `tools/` and `parts/SHA256SUMS`.

Deeper verification of the application payload — the ASAR per-file digests and block
hashes, the unpacked native modules, and the Debian file list — is documented in
[ANALYSIS.md](ANALYSIS.md#verification).

## Layout

```
files/
  asar-manifest.json      per-file manifest of app.asar (872 entries)
  package.json            application manifest extracted from the ASAR root
  grok-bot.desktop        XDG desktop entry
  apparmor-profile        shipped AppArmor profile
metadata/
  control                 Debian control fields
  postinst, postrm        maintainer scripts
  md5sums                 121-file payload checksum list
  changelog.txt           upstream changelog (FPM boilerplate)
  debian-binary           format marker ("2.0\n")
parts/
  grok-bot_0.72.0_amd64.deb.part-00…02
  SHA256SUMS
tools/
  split.sh                split a .deb into 40 MiB parts
  reassemble.sh           rebuild and verify the .deb
hashes.sha256             digests of all committed artifacts
```

The ASAR manifest records, for every entry, its path, size, SHA-256 and offset inside
`app.asar`; entries stored outside the archive carry `unpacked: true` plus the digest of
the corresponding file under `app.asar.unpacked/`.

## What is not included

- The 210 MB Electron runtime binary `/opt/Grok Bot/grok-bot` — hashed but not stored
  (SHA-256 `f41a171f676da01f1a126e24e9fbfeb7af6d17456e924f3f9831ec637886d79c`).
- The extracted package tree outside `files/` and `metadata/`.

See [ANALYSIS.md](ANALYSIS.md) for the payload structure, dependency inventory, native
modules, telemetry stack, install-time behaviour, and the vendor-identity discrepancies.
