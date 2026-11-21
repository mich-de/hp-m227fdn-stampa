$log = "C:\Users\michde\AppData\Local\Temp\opencode\ipp_port_v2.log"
"=== $(Get-Date -Format 'dd/MM/yyyy HH:mm:ss') ===" | Set-Content $log -Encoding UTF8
function Say($m) { $m | Tee-Object -FilePath $log -Append }

$portName = "http://192.168.188.88/ipp/print"
$queue    = "HP M227fdn (IPP)"

Say ("admin: " + (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)))

# rimuovi coda e porta create prima (porta TCP/IP mascherata da URL)
if (Get-Printer -Name $queue -ErrorAction SilentlyContinue) {
    Remove-Printer -Name $queue -ErrorAction SilentlyContinue
    Say "coda rimossa"
}
if (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue) {
    Remove-PrinterPort -Name $portName -ErrorAction SilentlyContinue
    Say "porta rimossa"
}

# porta Internet vera (monitor inetmon, NIENTE PrinterHostAddress)
try {
    Add-PrinterPort -Name $portName -ErrorAction Stop
    Say "OK porta Internet creata"
} catch {
    Say ("ERRORE porta Internet: " + $_.Exception.Message)
}

Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue | ForEach-Object {
    Say ("porta: " + $_.Name + "  desc=" + $_.Description + "  monitor=" + $_.PortMonitor)
}

if (Get-PrinterPort -Name $portName -ErrorAction SilentlyContinue) {
    try {
        Add-Printer -Name $queue -DriverName "Microsoft IPP Class Driver" -PortName $portName -ErrorAction Stop
        Say "OK coda creata"
        Set-PrintConfiguration -PrinterName $queue -PaperSize A4 -ErrorAction SilentlyContinue | Out-Null
        Say "A4 impostato"
    } catch {
        Say ("ERRORE coda: " + $_.Exception.Message)
    }
} else {
    Say "porta assente: coda non creata"
}

Get-Printer -Name $queue -ErrorAction SilentlyContinue | ForEach-Object {
    Say ("coda: " + $_.Name + " | " + $_.DriverName + " | " + $_.PortName + " | " + $_.PrinterStatus)
}
Say "=== fine ==="
