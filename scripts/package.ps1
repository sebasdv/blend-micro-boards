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

# No usar Compress-Archive: en PS 5.1 genera entradas con '\' (invalido segun la
# spec ZIP) y el extractor de arduino-cli puede fallar. Se crean las entradas con '/'.
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
# Resolver la ruta real: $env:TEMP puede ser una ruta corta 8.3 y descuadrar el recorte.
$stagingFull = (Get-Item $staging).FullName
$prefixLen = (Split-Path $stagingFull).Length + 1
$fs = [System.IO.File]::Open($zip, 'Create')
$za = New-Object System.IO.Compression.ZipArchive($fs, 'Create')
try {
    Get-ChildItem -Recurse -File $staging | ForEach-Object {
        $entry = $_.FullName.Substring($prefixLen).Replace('\', '/')
        [void][System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile($za, $_.FullName, $entry)
    }
} finally {
    $za.Dispose()
    $fs.Dispose()
}

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
