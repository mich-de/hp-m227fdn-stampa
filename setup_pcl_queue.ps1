$log = "C:\Users\michde\AppData\Local\Temp\opencode\pcl_queue.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

$badPort = "http://192.168.188.88/ipp/print"
$badQueue = "HP M227fdn (IPP)"
$port = "IP_192.168.188.88"
$queue = "HP M227fdn (PCL)"

Say ("admin: " + (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))

# 1) pulizia coda/porta IPP inutile (niente Internet Port Monitor su questo Windows)
if (Get-Printer -Name $badQueue -ErrorAction SilentlyContinue) {
    Remove-Printer -Name $badQueue -Force -ErrorAction SilentlyContinue
    Say "rimossa coda $badQueue"
}
Start-Sleep -Seconds 2
if (Get-PrinterPort -Name $badPort -ErrorAction SilentlyContinue) {
    try { Remove-PrinterPort -Name $badPort -ErrorAction Stop; Say "rimossa porta $badPort" }
    catch { Say ("porta non rimossa: " + $_.Exception.Message) }
}

# 2) porta TCP/IP standard verso 9100
if (-not (Get-PrinterPort -Name $port -ErrorAction SilentlyContinue)) {
    try { Add-PrinterPort -Name $port -PrinterHostAddress "192.168.188.88" -ErrorAction Stop; Say "OK porta $port" }
    catch { Say ("ERRORE porta: " + $_.Exception.Message) }
} else { Say "porta $port gia' presente" }

# 3) driver: prova i nomi tipici della famiglia M227-M231 (Windows Update)
$candidates = @(
  "HP LaserJet MFP M227-M231 PCL-6",
  "HP LaserJet MFP M227-M231 PCL-5",
  "HP LaserJet Pro MFP M227-M231 PCL-6",
  "HP LaserJet MFP M227-M231 PCL6",
  "HP LaserJet MFP M227-M231 PCL5"
)
$ok = $null
Say "--- driver gia' installati ---"
Get-PrinterDriver | ForEach-Object { Say ("  " + $_.Name) }
foreach ($d in $candidates) {
    if (Get-PrinterDriver -Name $d -ErrorAction SilentlyContinue) { $ok = $d; Say "driver presente: $d"; break }
    try {
        Add-PrinterDriver -Name $d -ErrorAction Stop
        $ok = $d; Say "OK driver installato: $d"; break
    } catch {
        Say ("no driver $d : " + $_.Exception.Message)
    }
}

# 4) coda
if ($ok) {
    try {
        Add-Printer -Name $queue -DriverName $ok -PortName $port -ErrorAction Stop
        Say "OK coda $queue con $ok"
        Set-PrintConfiguration -PrinterName $queue -PaperSize A4 -ErrorAction SilentlyContinue | Out-Null
        Say "A4 impostato"
        Get-Printer -Name $queue | ForEach-Object { Say ("coda: " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName + " | " + $_.PrinterStatus) }
    } catch { Say ("ERRORE coda: " + $_.Exception.Message) }
} else {
    Say "NESSUN DRIVER PCL DISPONIBILE su Windows Update"
}

Say ("code finali: " + ((Get-Printer | ForEach-Object { $_.Name }) -join " | "))
Say "=== fine ==="
