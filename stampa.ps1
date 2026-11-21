param(
  [Parameter(Mandatory=$true)][string]$Pdf,
  [double]$MarginMm = 10,
  [string]$Printer = "192.168.188.88",
  [string]$Media = "iso_a4_210x297mm",
  [ValidateSet("monochrome","color")][string]$Color = "monochrome",
  [ValidateSet("one-sided","two-sided-long-edge","two-sided-short-edge")][string]$Sides = "one-sided"
)

$ErrorActionPreference = "Stop"
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$fit  = Join-Path $here "pdf_fit.py"
if (-not (Test-Path $Pdf)) { throw "File non trovato: $Pdf" }
if (-not (Test-Path $fit)) { throw "Manca pdf_fit.py accanto a questo script" }

$out = Join-Path $env:TEMP ("fit_" + [IO.Path]::GetFileName($Pdf))
python $fit $Pdf $out $MarginMm
if ($LASTEXITCODE -ne 0) { throw "Scaling PDF fallito" }

$enc = [Text.Encoding]::ASCII
$ms  = New-Object System.IO.MemoryStream
function W([byte[]]$b){ $ms.Write($b,0,$b.Length) }
function BE16([int]$v){ [byte[]]@([byte](($v -shr 8) -band 0xFF),[byte]($v -band 0xFF)) }
function BE32([int]$v){ [byte[]]@([byte](($v -shr 24) -band 0xFF),[byte](($v -shr 16) -band 0xFF),[byte](($v -shr 8) -band 0xFF),[byte]($v -band 0xFF)) }
function Attr([byte]$tag,[string]$n,[string]$v){
  W ([byte[]]@($tag)); $nb=$enc.GetBytes($n); W (BE16 $nb.Length); W $nb
  $vb=$enc.GetBytes($v); W (BE16 $vb.Length); W $vb
}

W ([byte[]]@(0x02,0x00)); W (BE16 0x0002); W (BE32 (Get-Random -Minimum 2 -Maximum 99999))
W ([byte[]]@(0x01))
Attr 0x47 "attributes-charset" "utf-8"
Attr 0x48 "attributes-natural-language" "it"
Attr 0x45 "printer-uri" "ipp://$Printer/ipp/print"
Attr 0x42 "requesting-user-name" $env:USERNAME
Attr 0x42 "job-name" ([IO.Path]::GetFileName($Pdf))
Attr 0x49 "document-format" "application/pdf"
Attr 0x44 "media" $Media
Attr 0x44 "print-color-mode" $Color
Attr 0x44 "sides" $Sides
Attr 0x44 "print-scaling" "none"
W ([byte[]]@(0x03))
W ([IO.File]::ReadAllBytes($out))

$req = Join-Path $env:TEMP "ipp_job.bin"
[IO.File]::WriteAllBytes($req, $ms.ToArray())
$resp = Join-Path $env:TEMP "ipp_job.resp"
& curl.exe -s --max-time 180 --data-binary "@$req" -H "Content-Type: application/ipp" "http://$Printer/ipp/print" -o $resp
$b = [IO.File]::ReadAllBytes($resp)
$st = "0x{0:X2}{1:X2}" -f $b[2],$b[3]
if ($st -eq "0x0000") { "OK  $(Split-Path -Leaf $Pdf)  margine ${MarginMm}mm  $Media  $Sides  $Color  -> $Printer" }
else { "ERRORE $st" }
