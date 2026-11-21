# Stampa HP LaserJet MFP M227fdn — appunti e script

Raccolta di script e note per far stampare correttamente una **HP LaserJet MFP M227fdn**
da Windows 11 **ARM64** (Snapdragon) e da Android, con PDF A4, monocromatici e senza margine
superiore tagliato.

## Contenuto

| File | Cosa fa |
|---|---|
| `stampa.ps1` | stampa un PDF senza driver: pre-scala il contenuto e lo invia in IPP alla stampante |
| `pdf_fit.py` | motore di scaling (pypdf): riduce il PDF e lo centra con margine configurabile |
| `setup_pcl6_queue.ps1` | crea porta TCP/IP 9100 + coda con `Microsoft PCL6 Class Driver`, default A4 (richiede admin) |
| `restart_spooler.ps1` | riavvia il servizio Spooler (richiede admin) |
| `setup_ipp_queue.ps1`, `setup_ipp_port_v2.ps1` | tentativi di coda IPP su Windows senza Internet Port Monitor (non funzionanti: documentazione) |
| `install_hp_driver.ps1`, `install_hp_driver2.ps1` | tentativi di installazione driver HP x64 su ARM64 (non applicabili) |
| `setup_pcl_queue.ps1` | creazione coda cercando un driver HP PCL (fallisce senza driver ARM64) |
| `cleanup_queues.ps1`, `cleanup_queues2.ps1` | pulizia code/porte/driver di prova |
| `memory.md` | fatti stabili: rete, stampante, vincoli, convenzioni |
| `handover.md` | stato attuale, problemi aperti, prossimi passi |

## Uso rapido

```powershell
cd .\hp
.\stampa.ps1 -Pdf "C:\percorso\documento.pdf"                 # A4, mono, fronte singolo, margine 10 mm
.\stampa.ps1 -Pdf "C:\percorso\documento.pdf" -MarginMm 6     # margine più stretto, testo più grande
.\stampa.ps1 -Pdf "C:\percorso\documento.pdf" -Sides two-sided-long-edge
```

Richiede `python` con `pypdf` installato e la stampante raggiungibile su `192.168.188.88` (modificabile
con `-Printer`).

## Le tre cose che contano

1. **Margine non stampabile 4,23 mm**: la M227 non stampa vicino al bordo e il firmware 2019 **ignora**
   l'attributo IPP `print-scaling`. La scala va applicata dentro il PDF prima dell'invio.
2. **Windows su ARM64 non installa driver di stampa x64** (nessuna emulazione). Servono driver nativi
   ARM64: vanno bene quelli inbox `Microsoft PCL6/PS Class Driver` sulla porta TCP/IP 9100.
3. **PdfCraft (ArtCraft) non stampa con `Microsoft IPP Class Driver` su porta WSD**: fallisce con
   `Failed to correct dev mode via DocumentProperties`. Con un driver PCL6 la stampa funziona.
