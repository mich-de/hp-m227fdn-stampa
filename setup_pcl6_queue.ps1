$log = "C:\Users\michde\AppData\Local\Temp\opencode\pcl6_queue.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

$drv   = "Microsoft PCL6 Class Driver"
$port  = "IP_192.168.188.88"
$queue = "HP M227fdn (PCL)"

Say ("admin: " + (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))

try { Add-PrinterDriver -Name $drv -ErrorAction Stop; Say "OK driver $drv" }
catch { Say ("ERRORE driver: " + $_.Exception.Message) }

if (-not (Get-PrinterPort -Name $port -ErrorAction SilentlyContinue)) {
    try { Add-PrinterPort -Name $port -PrinterHostAddress "192.168.188.88" -ErrorAction Stop; Say "OK porta $port" }
    catch { Say ("ERRORE porta: " + $_.Exception.Message) }
} else { Say "porta $port gia' presente" }

if (Get-Printer -Name $queue -ErrorAction SilentlyContinue) { Remove-Printer -Name $queue -Force -ErrorAction SilentlyContinue; Say "coda preesistente rimossa" }

try {
    Add-Printer -Name $queue -DriverName $drv -PortName $port -ErrorAction Stop
    Say "OK coda $queue"
    Set-PrintConfiguration -PrinterName $queue -PaperSize A4 -ErrorAction SilentlyContinue | Out-Null
    Get-PrintConfiguration -PrinterName $queue | ForEach-Object { Say ("  config: " + $_.PaperSize + " / " + $_.DuplexingMode + " / colore=" + $_.Color) }
} catch { Say ("ERRORE coda: " + $_.Exception.Message) }

Get-Printer -Name $queue -ErrorAction SilentlyContinue | ForEach-Object { Say ("coda: " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName + " | " + $_.PrinterStatus) }
Say "=== fine ==="
