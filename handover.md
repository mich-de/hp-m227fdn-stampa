# handover.md — stato attuale

## Obiettivo
Stampare da telefono Android e da PC (PdfCraft incluso) sulla HP LaserJet MFP M227fdn,
A4, monocromatica, senza margine superiore tagliato.

## Fatto
- Telefono: HP Print Service Plugin disabilitato (perdeva la cache device), si usa **Mopria**; Drive non
  materializza i documenti, quindi PDF locale. Test superato.
- PC: **coda nuova `HP M227fdn (PCL)`** (Microsoft PCL6 Class Driver, porta TCP/IP 9100), A4, mono, **predefinita**.
  Vecchia coda WSD rimossa.
- **PdfCraft ora stampa**: verificato da CLI (`pdfcraft-cli run`), 2 job inviati, contatore pagine +2.
  Causa del blocco: `Microsoft IPP Class Driver` su porta WSD → errore `Failed to correct dev mode via DocumentProperties`.
- Margine tagliato risolto due volte:
  - via PdfCraft: opzione "adatta alla pagina" (scala del driver PCL6);
  - via `stampa.ps1` (IPP diretto): PDF pre-scalato 90,5% + margine 10 mm, invio `print-scaling=none`.
- Default coda corretto da Letter a A4 (era la causa degli eventi "Formato carta errato" sul pannello).

## Da sapere / problemi aperti
- Windows è **ARM64**: i driver HP x64 non si installano (nessuna emulazione per i driver di stampa).
  Se in futuro serve un driver HP vero, deve essere un pacchetto **ARM64**.
- Manca `inetmon`/`inetpp` (Internet Port Monitor): niente porte IPP `http://` native. Non è stato riparato
  (richiederebbe ripristino dei componenti di stampa Windows).
- Porta residua non rimovibile: `http://192.168.188.88/ipp/print` ("in uso"), inutilizzata. Innocua.
- Il driver HP x64 scaricato dal catalog WU (`oem79.inf`) è stato installato e poi **rimosso** con pnputil.
- IP in DHCP (lease ~10 giorni): se la stampante non risponde, verificare ancora `192.168.188.88`.

## Prossimi passi possibili
1. Riserva DHCP nel FRITZ!Box per la MAC della stampante (la trovi su `/DevMgmt/ProductConfigDyn.xml`).
2. Se serve stampa affidata al telefono in modo affidabile: Mopria + PDF locale.
3. Se PdfCraft dovesse tornare a non stampare dopo un aggiornamento di Windows: ricreare la coda con
   `setup_pcl6_queue.ps1` (verifica che il driver resti `Microsoft PCL6 Class Driver`).
