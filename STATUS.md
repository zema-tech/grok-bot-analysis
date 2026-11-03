# Grok Bot — preparazione completata (sandbox Grok)

Data: 2026-11-03 (aggiornato: hosting `.deb`)

## Cosa è stato fatto

1. Clone shallow del repo `zema-tech/grok-bot-analysis`
2. Ricomposizione `.deb` da `parts/` → **hash OK**
   - File: `grok-bot_0.72.0_amd64.deb`
   - Size: 106 074 508 bytes
   - SHA-256: `f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd`
3. Estrazione di prova del payload (~351 MB)
4. Script: `tools/run-on-e2b-desktop.sh`, `tools/download-deb.sh`

## Hosting del `.deb` intero su GitHub

| Metodo | Limite | Adatto? |
|--------|--------|--------|
| Commit nel tree git | **100 MiB hard block** | No (file ~101 MiB) |
| Git LFS | 2 GB/file, ma quota storage/bandwidth free limitata | Possibile, non ideale per un installer |
| **GitHub Releases** | **2 GiB/file**, nessun cap di banda sul download | **Sì — soluzione consigliata** |
| `parts/` già nel repo | 3× <40 MiB | Funziona sempre come fallback |

### Una tantum: caricare l’asset (UI o `gh`)

1. Ricompila in locale: `./tools/reassemble.sh`
2. Crea release tag `v0.72.0` su  
   https://github.com/zema-tech/grok-bot-analysis/releases/new  
   oppure:
   ```bash
   gh release create v0.72.0 grok-bot_0.72.0_amd64.deb \
     --title "grok-bot 0.72.0 deb" \
     --notes "Full Debian package (SHA-256 f79aff93…). Same bytes as parts/ reassembly."
   ```
3. Chiunque può poi ottenere il file con:
   ```bash
   ./tools/download-deb.sh
   ```
   (prova prima l’URL del release, altrimenti ricompone da `parts/`)

## Layout rilevante

```
parts/                         # part-00..02 + SHA256SUMS
tools/reassemble.sh
tools/split.sh
tools/download-deb.sh          # Release asset oppure parts/
tools/run-on-e2b-desktop.sh
STATUS.md
```

## Prossimo passo (E2B Hobby free)

```bash
git clone https://github.com/zema-tech/grok-bot-analysis.git
cd grok-bot-analysis
./tools/download-deb.sh          # o ./tools/reassemble.sh
chmod +x tools/run-on-e2b-desktop.sh
./tools/run-on-e2b-desktop.sh
```

## Note

- Pacchetto proprietario; uso solo in ambienti isolati di analisi.
- MicroVM: spesso serve `--no-sandbox` (già nello script di launch).
