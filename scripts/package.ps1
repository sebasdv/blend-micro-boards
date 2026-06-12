# Genera dist\redbearlab-avr-<version>.zip y actualiza checksum/size en el JSON.
param([string]$Version = "2.0.0")

$ErrorActionPreference = "Stop"
$root = Split-Path $PSScriptRoot -Parent
$staging = Join-Path $env:TEMP "rbl-pkg\redbearlab-avr-$Version"
$dist = Join-Path $root "dist"
$zip = Join-Path $dist "redbearlab-avr-$Version.zip"

if (Test-Path $staging) { Remove-Item -Recurse -Force $staging }
New-Item -ItemType Directory -Force $staging, $dist | Out-Null

# El ZIP debe contener una unica carpeta raiz con la plataforma dentro.
Copy-Item -Recurse "$root\redbearlab\avr\*" $staging
if (Test-Path $zip) { Remove-Item -Force $zip }
Compress-Archive -Path $staging -DestinationPath $zip

$hash = (Get-FileHash $zip -Algorithm SHA256).Hash.ToLower()
$size = (Get-Item $zip).Length

$jsonPath = Join-Path $root "package_redbearlab_index.json"
$json = Get-Content $jsonPath -Raw | ConvertFrom-Json
$platform = $json.packages[0].platforms[0]
$platform.version = $Version
$platform.checksum = "SHA-256:$hash"
$platform.size = "$size"
$out = $json | ConvertTo-Json -Depth 10
# Sin BOM: el parser del IDE/arduino-cli rechaza JSON con BOM.
[System.IO.File]::WriteAllText($jsonPath, $out, (New-Object System.Text.UTF8Encoding($false)))

Write-Host "ZIP: $zip"
Write-Host "SHA-256: $hash"
Write-Host "Size: $size"
