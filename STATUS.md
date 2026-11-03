# Grok Bot — preparazione completata (sandbox Grok)

Data: 2026-11-03

## Cosa è stato fatto

1. Clone shallow del repo `zema-tech/grok-bot-analysis`
2. Ricomposizione `.deb` da `parts/` → **hash OK**
   - File: `grok-bot_0.72.0_amd64.deb`
   - Size: 106 074 508 bytes
   - SHA-256: `f79aff93ecb923c44ce240b435ccd91b7144081738ae6e207e94ab9eadd710dd`
3. Estrazione di prova del payload (~351 MB)
   - Binario Electron: `opt/Grok Bot/grok-bot` (~201 MB)
   - ASAR: `resources/app.asar` (~46 MB)
   - package.json name interno: `sand` / productName `Grok Bot` 0.72.0
4. Script pronto per E2B Desktop: `tools/run-on-e2b-desktop.sh`

## Layout rilevante

```
parts/                         # part-00..02 + SHA256SUMS (commesso)
tools/reassemble.sh
tools/split.sh
tools/run-on-e2b-desktop.sh    # launch su desktop cloud
metadata/
files/
STATUS.md
```

Il `.deb` ricomposto **non** è nel repo (limite GitHub 100 MiB): va ricostruito con `./tools/reassemble.sh`.

## Prossimo passo (E2B Hobby free)

1. Account [e2b.dev](https://e2b.dev) Hobby (free, $100 credit, no card)
2. Sandbox con template **Desktop** (GUI), non `base`
3. `git clone` di questo repo nella sandbox
4. Esegui:
   ```bash
   chmod +x tools/run-on-e2b-desktop.sh
   ./tools/run-on-e2b-desktop.sh
   ```
   oppure in background:
   ```bash
   HEADLESS_LAUNCH=1 ./tools/run-on-e2b-desktop.sh
   ```
5. Guarda lo stream VNC/desktop di E2B

## Dipendenze Debian (dal control)

`libgtk-3-0 libnotify4 libnss3 libxss1 libxtst6 xdg-utils libatspi2.0-0 libuuid1 libsecret-1-0 libasound2 libgbm1 libxkbcommon0 libdrm2`

## Note

- Il pacchetto è **proprietario**; questo lavoro è solo preparazione tecnica per esecuzione in ambiente isolato.
- In microVM/container serve quasi sempre `--no-sandbox`.
- Senza DISPLAY serve Xvfb (incluso nello script) o meglio il template Desktop E2B.
