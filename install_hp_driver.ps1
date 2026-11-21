$log = "C:\Users\michde\AppData\Local\Temp\opencode\hp_driver_install.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

$dir   = "C:\Users\michde\AppData\Local\Temp\opencode\hp_m227"
$inf   = Join-Path $dir "hpsw642a4_x64.inf"
$drv   = "HP LaserJet MFP M227-M231 PCL-6 (V4)"
$port  = "IP_192.168.188.88"
$queue = "HP M227fdn (PCL)"

Say ("admin: " + (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))
Say ("inf: " + (Test-Path $inf))

Say "--- pnputil add-driver ---"
$out = & pnputil.exe /add-driver $inf /install 2>&1
$out | ForEach-Object { Say ("  " + $_) }

Say "--- Add-PrinterDriver ---"
try {
    Add-PrinterDriver -Name $drv -InfPath $inf -ErrorAction Stop
    Say "OK driver: $drv"
} catch {
    Say ("ERRORE Add-PrinterDriver: " + $_.Exception.Message)
    try { Add-PrinterDriver -Name $drv -ErrorAction Stop; Say "OK driver (senza infpath)" } catch { Say ("ERRORE 2: " + $_.Exception.Message) }
}

Say "--- driver installati ---"
Get-PrinterDriver | ForEach-Object { Say ("  " + $_.Name) }

if (Get-Printer -Name $queue -ErrorAction SilentlyContinue) {
    Remove-Printer -Name $queue -Force -ErrorAction SilentlyContinue
    Say "coda $queue rimossa (ricreo)"
}
if (-not (Get-PrinterPort -Name $port -ErrorAction SilentlyContinue)) {
    Add-PrinterPort -Name $port -PrinterHostAddress "192.168.188.88" -ErrorAction SilentlyContinue
    Say "porta $port creata"
}

try {
    Add-Printer -Name $queue -DriverName $drv -PortName $port -ErrorAction Stop
    Say "OK coda: $queue"
    Set-PrintConfiguration -PrinterName $queue -PaperSize A4 -ErrorAction SilentlyContinue | Out-Null
    Get-PrintConfiguration -PrinterName $queue | ForEach-Object { Say ("  config: " + $_.PaperSize + " / " + $_.DuplexingMode + " / colore=" + $_.Color) }
} catch {
    Say ("ERRORE coda: " + $_.Exception.Message)
}

Get-Printer -Name $queue -ErrorAction SilentlyContinue | ForEach-Object { Say ("coda: " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName + " | " + $_.PrinterStatus) }
Say "=== fine ==="
