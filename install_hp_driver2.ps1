$log = "C:\Users\michde\AppData\Local\Temp\opencode\hp_driver_install2.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

$dir   = "C:\Users\michde\AppData\Local\Temp\opencode\hp_m227"
$inf   = Join-Path $dir "hpsw642a4_x64.inf"
$drv   = "HP LaserJet MFP M227-M231 PCL-6 (V4)"
$port  = "IP_192.168.188.88"
$queue = "HP M227fdn (PCL)"

Say "--- printui /ia ---"
& rundll32.exe printui.dll,PrintUIEntry /ia /m $drv /f $inf /q
Start-Sleep -Seconds 5

Say "--- driver installati ---"
Get-PrinterDriver | ForEach-Object { Say ("  " + $_.Name) }

if (-not (Get-PrinterDriver -Name $drv -ErrorAction SilentlyContinue)) {
    Say "driver NON registrato, provo Add-PrinterDriver -InfPath (percorso pubblicato)"
    $pub = (Get-ChildItem "C:\Windows\INF\oem*.inf" | Where-Object { (Select-String -Path $_.FullName -Pattern "M227-M231" -Quiet) } | Select-Object -First 1)
    if ($pub) {
        Say ("inf pubblicato: " + $pub.FullName)
        try { Add-PrinterDriver -Name $drv -InfPath $pub.FullName -ErrorAction Stop; Say "OK driver" }
        catch { Say ("ERRORE: " + $_.Exception.Message) }
    } else { Say "inf pubblicato non trovato" }
}

Get-PrinterDriver | ForEach-Object { Say ("  dopo: " + $_.Name) }

if (Get-PrinterDriver -Name $drv -ErrorAction SilentlyContinue) {
    if (Get-Printer -Name $queue -ErrorAction SilentlyContinue) { Remove-Printer -Name $queue -Force -ErrorAction SilentlyContinue }
    if (-not (Get-PrinterPort -Name $port -ErrorAction SilentlyContinue)) {
        try { Add-PrinterPort -Name $port -PrinterHostAddress "192.168.188.88" -ErrorAction Stop; Say "OK porta $port" } catch { Say ("ERRORE porta: " + $_.Exception.Message) }
    } else { Say "porta $port presente" }
    try {
        Add-Printer -Name $queue -DriverName $drv -PortName $port -ErrorAction Stop
        Say "OK coda $queue"
        Set-PrintConfiguration -PrinterName $queue -PaperSize A4 -ErrorAction SilentlyContinue | Out-Null
        Get-Printer -Name $queue | ForEach-Object { Say ("coda: " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName + " | " + $_.PrinterStatus) }
    } catch { Say ("ERRORE coda: " + $_.Exception.Message) }
} else {
    Say "driver non disponibile: coda non creata"
}
Say "=== fine ==="
