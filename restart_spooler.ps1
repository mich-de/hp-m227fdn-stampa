$log = "C:\Users\michde\AppData\Local\Temp\opencode\spooler_restart.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }
Say "admin: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"
try {
    Restart-Service -Name Spooler -Force -ErrorAction Stop
    Say "OK spooler riavviato"
} catch {
    Say "ERRORE restart spooler: $($_.Exception.Message)"
}
Start-Sleep -Seconds 4
Say ("stato spooler: " + (Get-Service Spooler).Status)
Say ("porte: " + ((Get-PrinterPort | ForEach-Object { $_.Name }) -join " | "))
Say ("code: " + ((Get-Printer | ForEach-Object { $_.Name }) -join " | "))
Say "=== fine ==="
