$ErrorActionPreference = "Continue"
$log = "C:\Users\michde\AppData\Local\Temp\opencode\ipp_queue_setup.log"
function Say($m) { $m | Tee-Object -FilePath $log -Append }

"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
Say "admin: $(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))"

$portName = "http://192.168.188.88/ipp/print"
$queue    = "HP M227fdn (IPP)"
$driver   = "Microsoft IPP Class Driver"

# 1) porta IPP
if (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue) {
    Say "porta gia' presente: $portName"
} else {
    try {
        Add-PrinterPort -Name $portName -PrinterHostAddress "192.168.188.88" -ErrorAction Stop
        Say "OK porta creata: $portName"
    } catch {
        Say "ERRORE porta: $($_.Exception.Message)"
        try {
            Add-PrinterPort -Name $portName -ErrorAction Stop
            Say "OK porta creata (secondo tentativo): $portName"
        } catch {
            Say "ERRORE porta (2): $($_.Exception.Message)"
        }
    }
}

Say "--- porte disponibili ---"
Get-PrinterPort | ForEach-Object { Say ("  " + $_.Name + "  [" + $_.Description + "]") }

# 2) coda
if (Get-Printer -Name $queue -ErrorAction SilentlyContinue) {
    Say "coda gia' presente: $queue"
} else {
    try {
        Add-Printer -Name $queue -DriverName $driver -PortName $portName -ErrorAction Stop
        Say "OK coda creata: $queue"
    } catch {
        Say "ERRORE coda: $($_.Exception.Message)"
    }
}

Start-Sleep -Seconds 2

# 3) verifica
if (Get-Printer -Name $queue -ErrorAction SilentlyContinue) {
    Say "--- coda ---"
    Get-Printer -Name $queue | Select-Object Name,DriverName,PortName,PrinterStatus | ForEach-Object {
        Say ("  " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName + " | " + $_.PrinterStatus)
    }
    try {
        Set-PrintConfiguration -PrinterName $queue -PaperSize A4 -ErrorAction Stop
        Say "OK default carta A4"
    } catch { Say "ERRORE Set-PrintConfiguration: $($_.Exception.Message)" }
    try {
        Get-PrintConfiguration -PrinterName $queue | Select-Object PaperSize,DuplexingMode,Color | ForEach-Object {
            Say ("  config: " + $_.PaperSize + " / " + $_.DuplexingMode + " / colore=" + $_.Color)
        }
    } catch { Say "ERRORE lettura config: $($_.Exception.Message)" }
} else {
    Say "coda NON creata"
}

Say "=== fine ==="
