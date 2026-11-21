# HP LaserJet MFP M227fdn printing — notes and scripts

Scripts and notes to get an **HP LaserJet MFP M227fdn** printing correctly from Windows 11
**ARM64** (Snapdragon) and from Android: A4, monochrome, single-sided, with no clipped top margin.

## Contents

| File | What it does |
|---|---|
| `stampa.ps1` | print a PDF without a driver: pre-scales the content, then sends it over IPP |
| `pdf_fit.py` | scaling engine (pypdf): shrinks the PDF and centres it with a configurable margin |
| `setup_pcl6_queue.ps1` | creates a TCP/IP 9100 port + a queue with `Microsoft PCL6 Class Driver`, A4 default (needs admin) |
| `restart_spooler.ps1` | restarts the Spooler service (needs admin) |
| `setup_ipp_queue.ps1`, `setup_ipp_port_v2.ps1` | attempts at an IPP queue on Windows without the Internet Port Monitor (do not work: kept as documentation) |
| `install_hp_driver.ps1`, `install_hp_driver2.ps1` | attempts at installing the HP x64 driver on ARM64 (not applicable) |
| `setup_pcl_queue.ps1` | queue creation looking for an HP PCL driver (fails with no ARM64 driver) |
| `cleanup_queues.ps1`, `cleanup_queues2.ps1` | cleanup of test queues, ports and drivers |
| `memory.md` | stable facts: network, printer, constraints, conventions |
| `handover.md` | current state, open issues, next steps |

## Quick use

```powershell
.\stampa.ps1 -Pdf "C:\path\document.pdf"                 # A4, mono, single-sided, 10 mm margin
.\stampa.ps1 -Pdf "C:\path\document.pdf" -MarginMm 6     # tighter margin, bigger text
.\stampa.ps1 -Pdf "C:\path\document.pdf" -Sides two-sided-long-edge
```

Requires `python` with `pypdf` installed and the printer reachable on `192.168.188.88`
(change it with `-Printer`).

## The three things that matter

1. **4.23 mm non-printable margin**: the M227 cannot print near the sheet edge and the 2019
   firmware **ignores** the IPP `print-scaling` attribute. The scale must be applied inside the
   PDF before sending.
2. **Windows on ARM64 cannot install x64 print drivers** (no emulation). Native ARM64 drivers are
   required: the inbox `Microsoft PCL6/PS Class Driver` over a raw TCP/IP 9100 port works.
3. **PdfCraft (ArtCraft) does not print with `Microsoft IPP Class Driver` on a WSD port**: it fails
   with `Failed to correct dev mode via DocumentProperties`. With a PCL6 driver printing works.
