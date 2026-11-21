# handover.md — current state

## Goal
Print from an Android phone and from the PC (PdfCraft included) to the HP LaserJet MFP M227fdn:
A4, monochrome, no clipped top margin.

## Done
- Phone: HP Print Service Plugin disabled (it kept losing the device cache); **Mopria** is used instead.
  Google Drive never materialises the document, so print a locally saved PDF. Verified.
- PC: **new queue `HP M227fdn (PCL)`** (Microsoft PCL6 Class Driver, TCP/IP 9100 port), A4, mono,
  **set as default**. Old WSD queue removed.
- **PdfCraft prints now**: verified from the CLI (`pdfcraft-cli run`), 2 jobs sent, page counter +2.
  Root cause of the failure: `Microsoft IPP Class Driver` on a WSD port →
  `Failed to correct dev mode via DocumentProperties`.
- Clipped margin fixed two ways:
  - through PdfCraft: "fit to page" (scaling by the PCL6 driver);
  - through `stampa.ps1` (direct IPP): PDF pre-scaled to 90.5% with a 10 mm margin, sent with
    `print-scaling=none`.
- Queue default paper fixed from Letter to A4 (it was the cause of the "Wrong paper size" events on the
  printer control panel).

## Notes / open issues
- Windows is **ARM64**: HP x64 drivers cannot be installed (no print driver emulation). Any future HP
  driver must be an **ARM64** package.
- `inetmon`/`inetpp` (Internet Port Monitor) is missing: no native `http://` IPP ports. Not repaired
  (it would require restoring the Windows printing components).
- Leftover port that cannot be removed: `http://192.168.188.88/ipp/print` ("in use"), unused. Harmless.
- The HP x64 driver downloaded from the Windows Update catalog (`oem79.inf`) was installed and then
  **removed** with pnputil.
- The printer is on DHCP (~10 day lease): if it stops answering, check it is still `192.168.188.88`.

## Possible next steps
1. DHCP reservation in the FRITZ!Box for the printer MAC (see `/DevMgmt/ProductConfigDyn.xml`).
2. If phone printing must be rock solid: Mopria + a locally saved PDF.
3. If PdfCraft stops printing after a Windows update: recreate the queue with `setup_pcl6_queue.ps1`
   (check the driver stays `Microsoft PCL6 Class Driver`).
