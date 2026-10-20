# Analysis — `grok-bot_0.72.0_amd64.deb`

Static analysis of the Debian package archived in this repository. Nothing here was
obtained by running the application; every statement is derived from the package bytes.

- **Artifact**: `grok-bot_0.72.0_amd64.deb`, 106,074,508 bytes
- **SHA-256**: `f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd`
- **Format**: `ar` archive containing `debian-binary`, `control.tar.xz`, `data.tar.xz`
- **Declared installed size**: 358,266 KiB

## Scope and method

The parts in `parts/` were concatenated and verified against the recorded digest, then the
`ar` member table was parsed directly (60-byte headers, no external tools). `control.tar.xz`
and `data.tar.xz` were decompressed with Python `lzma`/`tarfile` (`filter="data"`) because no
`xz` binary is available in the analysis environment.

The application payload is an Electron bundle. Its archive, `resources/app.asar`, was parsed
per the ASAR container format: a 16-byte header of four little-endian `uint32` fields, whose
fourth field is the JSON header length, followed by the JSON directory index and the packed
file data. That index produced `files/asar-manifest.json`, which records every entry's path,
size, offset and digest.

Verification results are in [Verification](#verification).

## Package structure

| `ar` member | Size (bytes) |
| --- | --- |
| `debian-binary` | 4 (`2.0\n`) |
| `control.tar.xz` | 7,800 |
| `data.tar.xz` | 106,066,516 |

`control.tar.xz` holds six files: `control`, `md5sums`, `postinst`, `postrm`,
`changelog.txt` (upstream `changelog.gz` is generated from it), and the `debian-binary`
copy that FPM emits. All are archived verbatim under `metadata/`.

`control` (517 bytes) declares `Package: grok-bot`, `Version: 0.72.0`,
`Architecture: amd64`, `Section: default`, `Priority: optional`,
`Installed-Size: 358266`, `Homepage: https://cursor.com`,
`Maintainer`/`Vendor`: `SpaceXAI <hi@cursor.com>`, `License: unknown`, and the unusual
triplet `Conflicts`/`Provides`/`Replaces: sand`.

Runtime dependencies are the stock Electron set: `libgtk-3-0`, `libnotify4`, `libnss3`,
`libxss1`, `libxtst6`, `xdg-utils`, `libatspi2.0-0`, `libuuid1`, `libsecret-1-0`,
`libasound2t64 | libasound2`, `libgbm1`, `libxkbcommon0`, `libdrm2`, plus
`Recommends: libappindicator3-1`.

`changelog.txt` is FPM boilerplate — `* Package created with FPM.` — dated
`Sun, 18 Oct 2026 04:35:27 +0000`. It carries no upstream release history.

### Installed layout

```
/opt/Grok Bot/                       ~358 MB, 13 files + locales/ + resources/
/usr/bin/grok-bot                    → update-alternatives symlink
/usr/share/applications/grok-bot.desktop
/usr/share/icons/hicolor/{16,24,32,48,64,128,256,512}x*/apps/grok-bot.png
/usr/share/doc/grok-bot/changelog.gz
```

`md5sums` lists 121 files: 111 under `opt/`, 8 icons, 1 desktop entry, 1 doc file.

## Application payload

`/opt/Grok Bot/` is a standard Electron distribution:

| File | Bytes |
| --- | --- |
| `grok-bot` (ELF executable, not archived) | 210,087,128 |
| `LICENSES.chromium.html` | 20,008,180 |
| `icudtl.dat` | 11,002,272 |
| `resources.pak` | 7,055,888 |
| `libGLESv2.so` | 6,428,384 |
| `libvk_swiftshader.so` | 4,471,288 |
| `libffmpeg.so` | 2,752,696 |
| `libvulkan.so.1` | 2,540,808 |
| `chrome_crashpad_handler` | 1,570,368 |
| `v8_context_snapshot.bin` | 721,176 |
| `snapshot_blob.bin` | 346,432 |
| `libEGL.so` | 286,424 |
| `chrome_200_percent.pak` | 198,601 |
| `icon.png` (in `resources/`) | 152,146 |
| `chrome_100_percent.pak` | 120,284 |
| `LICENSE.electron.txt` | 1,096 |
| `vk_swiftshader_icd.json` | 107 |

`locales/` adds 55 `.pak` files. `resources/` contains `app.asar`, `app.asar.unpacked/`,
`apparmor-profile` and `icon.png`.

The executable is deliberately excluded from this archive; its digest is recorded in the
[README](README.md#what-is-not-included). `chrome-sandbox` (15,232 bytes, SHA-256
`2015304df43beff0b74409cdc4d858107efcde650d9bc8afb1288041d62cec4b`) is likewise not
stored, but its handling is described under [Install-time behaviour](#install-time-behaviour).

## `app.asar`

| Property | Value |
| --- | --- |
| Size | 47,553,823 bytes |
| SHA-256 | `b4c44d1230742d08c5b5e27ae216b644dc0d86df5583b48734e821c1856c3b28` |
| JSON header | 236,840 bytes |
| Data offset | 236,856 |
| Entries | 872 (836 packed, 36 unpacked) |
| Uncompressed total | 50,058,657 bytes |
| Unpacked total | 2,741,690 bytes |
| Executable-flagged entries | 0 |

The container is uncompressed — file "compression" in ASAR is not used here, so `size` and
on-disk extent coincide for packed entries. Every entry carries an `integrity` object with
`algorithm: SHA256`, a whole-file `hash`, `blockSize: 4194304` and per-block `blocks`; digests
are hex strings. Offsets are serialized as decimal strings and must be cast.

### Size distribution by directory

Recursive totals for the three trees that dominate the archive:

| Directory | Files | Bytes |
| --- | --- | --- |
| `dist/renderer` | 678 | 35,083,192 |
| `dist/electron-main` | 149 | 7,384,229 |
| `dist/deps` | 35 | 2,637,394 |

Within those, the largest immediate-parent groups are `dist/renderer/assets` (675 files,
35,076,105 bytes), `dist/electron-main` proper (6 files, 5,556,809 bytes — the main process
bundles), `dist/local-exec-daemon` (2 files, 3,778,392 bytes), the tree-sitter native
prebuilds (1,383,184 bytes), `dist/node-agent-coordinator` (976,680 bytes),
`dist/electron-preload` (6 files, 194,214 bytes) and `dist/electron-main/menubar-tray/assets`
(108 files, 162,958 bytes). The remainder of `dist/electron-main` is 55 per-locale string
catalogs (`el`, `ta`, `ru`, `uk`, `te`, `bn`, `th`, `mr`, `ur`, `hi`, `ar`, `he`, `ja`, …),
each a single file of 30–97 KB.

### Largest entries

| Entry | Bytes |
| --- | --- |
| `dist/renderer/assets/index.eager-app-Bmtrl2Zx.js` | 3,932,515 |
| `dist/local-exec-daemon/main.cjs` | 3,662,434 |
| `dist/electron-main/main-app.cjs` | 3,164,895 |
| `dist/renderer/assets/chunk-dist-C00JFfYi.js` | 1,465,205 |
| `dist/deps/tree-sitter-bash/prebuilds/linux-x64/tree-sitter-bash.node` | 1,383,184 |
| `dist/electron-main/proto.cjs` | 1,301,277 |
| `dist/renderer/assets/pdf.worker.min-qwK7q_zL.mjs` | 1,046,214 |
| `dist/node-agent-coordinator/main.cjs` | 976,680 |
| `dist/electron-main/main-core.cjs` | 963,157 |
| `dist/renderer/assets/index.eager-platform-BFGuCGzq.js` | 892,100 |
| `dist/renderer/assets/index.eager-vendor-cR6BHVc-.js` | 734,933 |
| `dist/renderer/assets/index-CMR1RvAA.css` | 699,092 |

The four-process split — `electron-main`, `electron-preload`, `renderer`, and a separate
`local-exec-daemon` — is visible directly in the layout. `local-exec-daemon/main.cjs` is the
second-largest file in the archive and is not part of the renderer.

### Extension histogram

| Extension | Count |
| --- | --- |
| `.js` | 635 |
| `.png` | 122 |
| `.cjs` | 50 |
| `.woff2` | 22 |
| `.json` | 13 |
| `.node` | 7 |
| `.svg` | 6 |
| `.css` | 5 |
| `.wav` | 5 |
| `.html` | 3 |
| `.wasm` | 1 |
| `.jpg` | 1 |
| `.mp3` | 1 |
| `.mjs` | 1 |

## Native modules

Thirty-six entries are stored outside the archive under `resources/app.asar.unpacked/`
because native binaries cannot be loaded from inside an ASAR. Besides node-gyp loaders,
`node-addon-api` and `runtime-deps-manifest.json`, these are:

| Module | File | Bytes |
| --- | --- | --- |
| tree-sitter (bash grammar) | `tree-sitter-bash.node` | 1,383,184 |
| tree-sitter runtime binding | `tree_sitter_runtime_binding.node` | 678,240 |
| web-tree-sitter | `tree-sitter.wasm` | 185,642 |
| cursor-proclist | `cursor_proclist.node` | 148,632 |
| onepassword connection service | `onepassword-connection-service.cjs` | 104,296 |
| web-tree-sitter JS | `tree-sitter.js` | 75,606 |
| sand-devicecheck | `sand_devicecheck.node` | 31,352 |
| sand-window-capture | `sand_window_capture.node` | 23,016 |
| sand-notification-settings | `sand_notification_settings.node` | 22,952 |
| sand-card-text-recognition | `sand_card_text_recognition.node` | 18,848 |

`dist/deps/runtime-deps-manifest.json` (1,015 bytes) enumerates the modules that must be
unpacked and copied at build time, including five `sand-*` natives plus tree-sitter and
tree-sitter-bash. All 36 unpacked files were digested individually and are recorded in the
manifest with `unpacked: true`.

## Application manifest and dependencies

`files/package.json` (4,556 bytes) is the extracted ASAR root manifest. It has exactly these
top-level keys: `name`, `productName`, `desktopName`, `version`, `description`, `author`,
`homepage`, `private`, `type`, `main`, `dependencies`, `sandTrack`, `sandBuiltAt`.

Notable absences: **no `license`**, no `scripts`, no `build`, no `devDependencies`.

| Field | Value |
| --- | --- |
| `name` | `sand` |
| `productName` | `Grok Bot` |
| `desktopName` | `grok-bot.desktop` |
| `version` | `0.72.0` |
| `description` | `Grok Bot desktop agent` |
| `author` | `SpaceXAI` |
| `homepage` | `https://cursor.com` |
| `private` | `true` |
| `type` | `module` |
| `main` | `dist/electron-main/main.cjs` |
| `sandTrack` | `stable` |
| `sandBuiltAt` | `2026-10-18T04:32:03.961Z` |

`dependencies` contains 101 entries: 49 `workspace:*` packages and 52 third-party or
file-referenced packages. The workspace set is a fully internal monorepo — `@anysphere/agent`,
`-agent-client`, `-agent-core`, `-agent-exec`, `-agent-kv`, `-agent-store-ids`,
`-agent-store-sync`, `-agent-summarization`, `-agent-transcript`, `-analytics-client`,
`-analytics-types`, `-browser-smoke`, `-canvas-shared`, `-card-photo-text`,
`-chat-inference`, `-chat-inference-proto`, `-codebase-telemetry`, `-constants`, `-context`,
`-context-rpc`, `-cursor-config`, `-cursor-plugins`, `-draft-revision`, `-dune`,
`-dune-reliability`, `-file-kind-icons`, `-grok-bot`, `-grok-bot-harness`, `-link-preview`,
`-local-exec`, `-marketplace-category`, `-mcp-agent-exec`, `-mcp-core`, `-messages-mac`,
`-metrics`, `-model-selection`, `-orbit-client`, `-otel-proto`, `-proto`, `-redacted-protos`,
`-shell-exec`, `-slack-app-setup`, `-ui`, `-utils`, `-virtual`, `-voice-call-harness`,
`-xai-commerce-prepaid` — plus `@sand/client` and `@sand/shared`.

The third-party set includes:

- **UI/runtime**: `@base-ui/react` 1.8.0, `@dnd-kit/core` `^6.3.1`, `@dnd-kit/sortable`
  `^10.0.0`, `@dnd-kit/utilities` `^3.2.2`, `@floating-ui/dom` `^1.7.6`, `@tiptap/*`
- **RPC/protocol**: `@connectrpc/connect` `^1.6.1`, `@connectrpc/connect-node` `^1.6.1`,
  `@bufbuild/protobuf` 1.10.1, `ws` 8.21.3, `zod@catalog:`
- **i18n**: `@lingui/core` `^5.9.5`, `@lingui/react` `^5.9.5`, `emojibase-data` 17.0.0
- **Telemetry**: `@sentry/electron` 7.4.0, `@opentelemetry/*`, `@statsig/js-client`
- **Documents/media**: `pdfjs-dist` 5.4.296 (`pdf.worker.min-*.mjs` above), `mermaid`,
  `xlsx`, `mammoth`, `katex`, `mdast-util-from-markdown`
- **File/archives**: `adm-zip`, `cursor-proclist@file:../vscode/native-modules/cursor-proclist`
- **First-party natives**: `sand-card-text-recognition`, `sand-devicecheck`,
  `sand-notification-settings`, `sand-window-capture`

Companion binary `chrome_crashpad_handler` and the Sentry/OpenTelemetry/Statsig stack together
describe a crash- and usage-reporting path, though no endpoint configuration was recovered
statically here.

## Install-time behaviour

### `postinst`

1. **Launcher registration.** `update-alternatives --install /usr/bin/grok-bot grok-bot
   '/opt/Grok Bot/grok-bot' 100`, with a direct `ln -sf` fallback. Before that it removes a
   stale `/usr/bin/grok-bot` symlink if it does not already point at
   `/etc/alternatives/grok-bot`.
2. **Chromium sandbox mode.** If `unshare --user true` fails (user namespaces unavailable),
   it sets `chmod 4755` on `/opt/Grok Bot/chrome-sandbox`; otherwise `chmod 0755`. Which
   branch runs therefore depends on the target kernel's `kernel.unprivileged_userns_clone` /
   AppArmor restriction state, and the SUID branch grants a setuid-root helper.
3. **AppArmor.** Only when `apparmor_status --enabled` succeeds *and*
   `apparmor_parser --skip-kernel-load --debug` accepts the shipped profile, the file is
   copied to `/etc/apparmor.d/grok-bot` and loaded with
   `apparmor_parser --replace --write-cache --skip-read-cache`. Inline comments cite Electron
   issues 41066 (`kernel.apparmor_restrict_unprivileged_userns=1`, the Ubuntu 24.04 default)
   and 44414 (SUID `chrome-sandbox` `execvp` failing when the path contains a space — which
   `/opt/Grok Bot` does).
4. **Desktop integration.** `update-mime-database` and `update-desktop-database`.
5. **APT source registration.** Writes `/etc/apt/sources.list.d/grok-bot.sources` and
   dearmors an embedded key to `/usr/share/keyrings/grok-bot.gpg`. The embedded PGP block is
   processed by a shell function (`dearmor_without_gpg`) so `gpg` need not be installed; on
   failure it only warns ("grok-bot apt source not registered"). A helper preserves an
   existing `Enabled: no` field, so a user who disabled the source keeps it disabled after an
   upgrade. A comment explains that the internal suite is named `sand` because APT applies
   `Signed-By` to every source sharing a URI+Suite and errors when two entries disagree.

The shipped profile `files/apparmor-profile` is minimal:

```
abi <abi/4.0>,
include <tunables/global>
profile "grok-bot" "/opt/Grok Bot/grok-bot" flags=(unconfined) {
  userns,
  include if exists <local/grok-bot>
}
```

It is **unconfined** and exists only to grant `userns` to this binary, i.e. to satisfy
Electron's user-namespace sandbox path on restricted Ubuntu releases rather than to confine
the application.

### `postrm`

- Removes the alternative with `update-alternatives --remove 'grok-bot'
  '/opt/Grok Bot/grok-bot'` (guarded by a `type` check) or deletes the symlink directly.
- Unloads the AppArmor profile *before* deleting `/etc/apparmor.d/grok-bot`, and skips both
  when `ischroot` reports a chroot or `apparmor_status --enabled` fails.
- Only on `remove` or `purge` does it delete `grok-bot.sources` and the keyring; the
  `APT_SOURCE_PARTS` directory is resolved through `apt-config shell
  Dir::Etc::sourceparts/d`. Other dpkg modes intentionally keep the source, matching Debian
  policy for maintainer scripts.

### Desktop entry

`files/grok-bot.desktop` (229 bytes): `Name=Grok Bot`, `Exec=grok-bot %U`,
`Terminal=false`, `Type=Application`, `Icon=grok-bot`, `StartupWMClass=grok-bot`,
`Comment=Grok Bot desktop agent`, `Categories=Development`, and
`MimeType=x-scheme-handler/grokbot;x-scheme-handler/sand;`. The MIME line means the app
registers itself as the system handler for two custom URI schemes, `grokbot:` and `sand:`.

## Identity discrepancies

Three independent naming layers disagree:

| Layer | Value |
| --- | --- |
| Debian `control` | `Package: grok-bot`, `Vendor`/`Maintainer`: `SpaceXAI <hi@cursor.com>`, `Homepage: https://cursor.com` |
| APT signing key | `Anysphere Inc <security@anysphere.co>` |
| Internal app manifest | `name: "sand"`, workspace packages under `@anysphere/*`, `Conflicts`/`Provides`/`Replaces: sand` |

The package presents itself as a "Grok Bot" product from "SpaceXAI" pointing at `cursor.com`,
while its signing key identifies **Anysphere Inc** (the company behind Cursor) and its
internal module namespace is `sand`/`@anysphere`. The `sand` suite name in the APT source
matches that internal namespace. Treat the vendor metadata as branding rather than as an
independent attestation.

## Licensing

`control` declares `License: unknown`, and `files/package.json` has no `license` field. No
license text for the application itself is shipped.

Two license files *are* present, but they cover the bundled runtime, not the application:

- `LICENSE.electron.txt` (1,096 bytes) — Electron's MIT license.
- `LICENSES.chromium.html` (20,008,180 bytes) — Chromium/third-party license notices.

The `@anysphere/*` and `sand-*` code, the renderer bundles and the `local-exec-daemon` are
uncovered by any bundled grant. This archive is a private archival copy and analysis; it
grants no redistribution rights.

## Verification

Everything below was executed against this repository and the extracted package.

### ASAR per-file and block digests

The 836 packed entries were recomputed from `app.asar` and compared with the `integrity`
object embedded in the archive's own header — both the whole-file `hash` and every 4 MiB
`blocks[]` entry:

```
{"blockcheck": 836, "blockfail": 0, "match": 836, "mismatch": 0,
 "no_integrity": 0, "packed": 836, "unpacked": 36}
problems: 0
```

The 36 unpacked files were compared by size and digest against
`resources/app.asar.unpacked/`:

```
unpacked verified: 36  size mismatch: 0  missing: 0
```

Entry count cross-check: the manifest's `file_count` (872) equals the number of entries
walked in the ASAR header (872).

### Debian file list

`md5sums` was checked against the extracted payload:

```
md5sum -c --quiet ../c/md5sums   # EXIT=0
```

121 of 121 files matched.

### Archive integrity

```
cd parts && sha256sum -c SHA256SUMS        # 3/3 OK
sha256sum -c hashes.sha256 --quiet         # OK
./tools/reassemble.sh                      # OK: 106074508 bytes, sha256=f79aff93…
```

`hashes.sha256` covers `files/`, `metadata/`, `tools/` and `parts/SHA256SUMS`; the split
chunks are covered separately by `parts/SHA256SUMS` because they change whenever the split
size changes.

### Limitations

- The Electron executable and `chrome-sandbox` are not stored, so their digests are recorded
  but their contents were not analysed beyond hashing.
- No JavaScript was executed and no network endpoints were exercised; the telemetry stack is
  identified from declared dependencies, not from observed traffic.
- ASAR offsets and digests describe the archive as built; they do not attest that the shipped
  bundle corresponds to any public source release.
