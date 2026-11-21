# memory.md — Stampa HP M227fdn (progetto "hp")

## Contesto
- PC fisso: `snapdragon`, **Windows 11 ARM64** (Snapdragon X), IP `192.168.188.83` (WiFi `michele_5`)
- Router: FRITZ!Box `192.168.188.1`
- Stampante: **HP LaserJet MFP M227fdn** (G3Q79A), **Ethernet**, DHCP
  - IP `192.168.188.88`, hostname `NPI91EECE`, mDNS `NPI91EECE.local.`
  - S/N, MAC e UUID: **redatti** in questa copia pubblica (leggibili da `/DevMgmt/ProductConfigDyn.xml`)
  - Firmware `20190718` (2019) — **non aggiornato**
  - Porte: 80, 443, 631 (IPP/IPPS), 9100 (raw)
  - Linguaggi: PCLXL (PCL6), PCL5c, PostScript 3, PDF 1.7, AirPrint
- Telefono: **Galaxy S25 Edge** (`SM-S937B`), IP `192.168.188.69`

## Setup di stampa attuale (deciso il 22/11/2026)
- Coda Windows: **`HP M227fdn (PCL)`** — driver `Microsoft PCL6 Class Driver` (nativo ARM64),
  porta TCP/IP standard `IP_192.168.188.88` (raw 9100). **È la predefinita.**
  Default: A4, fronte singolo, monocromatica.
- Coda WSD precedente (`NPI91EECE (HP LaserJet MFP M227fdn)`, `Microsoft IPP Class Driver` su porta WSD) **rimossa**.
- Residuo cosmetico: porta inutilizzata denominata `http://192.168.188.88/ipp/print` (non rimovibile:
  "in uso"; innocua, non usata da nessuna coda).
- Stampa diretta IPP senza driver: `stampa.ps1` (pre-scala il PDF e invia a `http://192.168.188.88/ipp/print`).

## Fatti stabili / trappole
- **ARM64**: Windows su Snapdragon non installa driver di stampa x64 (niente emulazione).
  Il pacchetto HP `hpsw642a4_x64.inf` (catalog WU, 24,8 MB) viene importato come `arm64` ma senza modelli → inutilizzabile.
- Windows 11 ARM installa i driver **v3/v4 solo nativi ARM64**: inbox ci sono `Microsoft PCL6/PS/XPS Class Driver`,
  `Microsoft IPP Class Driver`, `Microsoft Print To PDF`, `Universal Print Class Driver`.
- **Manca il monitor "Internet Port"** (`inetmon`/`inetpp` assenti: evento 512 "InitializePrintProvider inetpp.dll fallito")
  → impossibile creare porte `http://…/ipp/print` reali. `Add-PrinterPort -PrinterHostAddress` con URL crea solo una
  porta TCP mascherata (non IPP).
- **Bug PdfCraft + driver IPP Class**: `doc_print` fallisce con
  `Failed to correct dev mode via DocumentProperties` (log: `could not resolve the printer's two-sided default`,
  `os error -2147418113` = E_UNEXPECTED). Succede solo con `Microsoft IPP Class Driver`; con driver v3
  (`Microsoft Print to PDF`) e con `Microsoft PCL6 Class Driver` funziona.
- Margine non stampabile = **4,23 mm** su tutti i lati; il firmware **ignora `print-scaling`** lato IPP.
  → per la stampa IPP diretta il PDF va pre-scalato (default `stampa.ps1`: 90,5%, margine 10 mm).
- Contatori (`TotalImpressions`) si aggiornano in NVRAM con ritardo di minuti: attendibili solo dopo 1-3 min.
- Cartucce HP originali: toner CF230A (60%), tamburo CF232A (60%). `GenuineHPSuppliesOnly = disabled`.

## Convenzioni
- Stampante di default = `HP M227fdn (PCL)`; PdfCraft stampa lì (A4, "adatta alla pagina", scala 100%).
- Stampa PDF senza driver: `cd C:\Users\michde\Downloads\hp; .\stampa.ps1 -Pdf <file> [-MarginMm 10] [-Sides two-sided-long-edge]`
- Diagnostica IPP in `%TEMP%\opencode\`: `ipp_all.ps1`, `getjob.ps1`, `parse_job.ps1`.
- Script di setup (richiedono UAC): `setup_pcl6_queue.ps1`, `install_hp_driver*.ps1`, `cleanup_queues*.ps1`.
- PdfCraft CLI per testare la stampa senza GUI:
  `pdfcraft-cli.exe run --script steps.json --report` con `doc_open` + `doc_print` (arg `doc`, non `document`).
- ADB: `C:\Users\michde\AppData\Local\Android\platform-tools\adb.exe` (serve Debug wireless attivo).
