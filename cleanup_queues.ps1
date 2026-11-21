$log = "C:\Users\michde\AppData\Local\Temp\opencode\cleanup.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

Say ("admin: " + (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))

# vecchia coda WSD (rotta con i driver v4)
$old = "NPI91EECE (HP LaserJet MFP M227fdn)"
if (Get-Printer -Name $old -ErrorAction SilentlyContinue) {
    try { Remove-Printer -Name $old -ErrorAction Stop; Say "OK rimossa coda WSD: $old" }
    catch { Say ("ERRORE rimozione coda: " + $_.Exception.Message) }
} else { Say "coda WSD gia' assente" }

# porta finta con URL
$badPort = "http://192.168.188.88/ipp/print"
if (Get-PrinterPort -Name $badPort -ErrorAction SilentlyContinue) {
    try { Remove-PrinterPort -Name $badPort -ErrorAction Stop; Say "OK rimossa porta $badPort" }
    catch { Say ("porta non rimossa: " + $_.Exception.Message) }
}

# pacchetto driver HP x64 inutile su ARM64
$pkgs = & pnputil.exe /enum-drivers 2>&1
$txt = $pkgs -join "`n"
$m = [regex]::Match($txt, 'Nome pubblicato:\s+oem79\.inf')
if ($m.Success) {
    $out = & pnputil.exe /delete-driver oem79.inf /uninstall 2>&1
    $out | ForEach-Object { Say ("  " + $_) }
} else { Say "oem79 non presente" }

Say "--- code finali ---"
Get-Printer | ForEach-Object { Say ("  " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName) }
Say ("default: " + (Get-CimInstance Win32_Printer | Where-Object Default | Select-Object -ExpandProperty Name))
Say "=== fine ==="
