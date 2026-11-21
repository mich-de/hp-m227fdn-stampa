# memory.md — HP M227fdn printing project

## Context
- Desktop PC: `snapdragon`, **Windows 11 ARM64** (Snapdragon X), IP `192.168.188.83`
- Router: FRITZ!Box `192.168.188.1`
- Printer: **HP LaserJet MFP M227fdn** (G3Q79A), **Ethernet**, DHCP
  - IP `192.168.188.88`, hostname `NPI91EECE`, mDNS `NPI91EECE.local.`
  - Serial number, MAC and UUID: **redacted** in this public copy (readable from `/DevMgmt/ProductConfigDyn.xml`)
  - Firmware `20190718` (2019) — **never updated**
  - Ports: 80, 443, 631 (IPP/IPPS), 9100 (raw)
  - PDLs: PCLXL (PCL6), PCL5c, PostScript 3, PDF 1.7, AirPrint

## Working print setup (decided 2026-11-22)
- Windows queue: **`HP M227fdn (PCL)`** — driver `Microsoft PCL6 Class Driver` (native ARM64),
  Standard TCP/IP port `IP_192.168.188.88` (raw 9100). **It is the default printer.**
  Defaults: A4, single-sided, monochrome.
- The previous WSD queue (`NPI91EECE (HP LaserJet MFP M227fdn)`, `Microsoft IPP Class Driver` on a WSD
  port) was **removed**.
- Cosmetic leftover: an unused port named `http://192.168.188.88/ipp/print` (cannot be removed,
  "in use"; harmless, no queue references it).
- Driverless direct IPP printing: `stampa.ps1` (pre-scales the PDF, sends to `http://192.168.188.88/ipp/print`).

## Stable facts / traps
- **ARM64**: Windows on Snapdragon cannot install x64 print drivers (no emulation for print drivers).
  The HP package `hpsw642a4_x64.inf` (Windows Update catalog, 24.8 MB) is imported as `arm64` but has
  no matching models → unusable.
- Windows 11 ARM ships only **native ARM64 v3/v4 drivers**: `Microsoft PCL6/PS/XPS Class Driver`,
  `Microsoft IPP Class Driver`, `Microsoft Print To PDF`, `Universal Print Class Driver`.
- The **Internet Port Monitor is missing** (`inetmon`/`inetpp` absent; event 512 "InitializePrintProvider
  inetpp.dll failed") → real `http://…/ipp/print` ports cannot be created. `Add-PrinterPort -PrinterHostAddress`
  with a URL only creates a TCP port with a URL-like name (not IPP).
- **PdfCraft + IPP Class Driver bug**: `doc_print` fails with
  `Failed to correct dev mode via DocumentProperties` (log: `could not resolve the printer's two-sided
  default`, `os error -2147418113` = E_UNEXPECTED). Only with `Microsoft IPP Class Driver`; it works with
  a v3 driver (`Microsoft Print to PDF`) and with `Microsoft PCL6 Class Driver`.
- Non-printable margin = **4.23 mm** on every side; the firmware **ignores `print-scaling`** on the IPP
  side. → for direct IPP printing the PDF must be pre-scaled (default in `stampa.ps1`: 90.5%, 10 mm margin).
- Impression counters (`TotalImpressions`) flush to NVRAM with minutes of delay: only reliable after 1–3 min.
- Genuine HP cartridges: toner CF230A (60%), drum CF232A (60%). `GenuineHPSuppliesOnly = disabled`.

## Conventions
- Default printer = `HP M227fdn (PCL)`; PdfCraft prints there (A4, "fit to page", scale 100%).
- Driverless PDF printing: `.\stampa.ps1 -Pdf <file> [-MarginMm 10] [-Sides two-sided-long-edge]`
- IPP diagnostics in `%TEMP%\opencode\`: `ipp_all.ps1`, `getjob.ps1`, `parse_job.ps1`.
- Setup scripts (need UAC): `setup_pcl6_queue.ps1`, `install_hp_driver*.ps1`, `cleanup_queues*.ps1`.
- PdfCraft CLI, to test printing without the GUI:
  `pdfcraft-cli.exe run --script steps.json --report` with `doc_open` + `doc_print` (the arg is `doc`,
  not `document`).
- ADB: `C:\Users\michde\AppData\Local\Android\platform-tools\adb.exe` (needs wireless debugging on).
- **Language: English** for documentation and replies (user preference).
