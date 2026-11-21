$log = "C:\Users\michde\AppData\Local\Temp\opencode\cleanup2.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

if (Get-Printer -Name "HP M227fdn (IPP)" -ErrorAction SilentlyContinue) {
    try { Remove-Printer -Name "HP M227fdn (IPP)" -ErrorAction Stop; Say "OK rimossa coda HP M227fdn (IPP)" }
    catch { Say ("ERRORE: " + $_.Exception.Message) }
}
Start-Sleep -Seconds 2
if (Get-PrinterPort -Name "http://192.168.188.88/ipp/print" -ErrorAction SilentlyContinue) {
    try { Remove-PrinterPort -Name "http://192.168.188.88/ipp/print" -ErrorAction Stop; Say "OK rimossa porta http" }
    catch { Say ("porta ancora in uso: " + $_.Exception.Message) }
}
Say "--- finale ---"
Get-Printer | ForEach-Object { Say ("  " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName) }
Get-PrinterPort | ForEach-Object { Say ("  porta: " + $_.Name) }
Say "=== fine ==="
