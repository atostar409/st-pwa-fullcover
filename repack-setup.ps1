# Regenerates the #D# base64 payload inside setup-mobile.bat from the
# extension files in this repository (manifest.json, index.js, README.md).
# Run this after every extension change, before committing.
$ErrorActionPreference = 'Stop'
$batPath = Join-Path $PSScriptRoot 'setup-mobile.bat'
$marker = 'REM ===== PAYLOAD'
$zipPath = Join-Path $env:TEMP 'pwa-fullcover-ext.zip'

Compress-Archive -Path @(
    (Join-Path $PSScriptRoot 'manifest.json'),
    (Join-Path $PSScriptRoot 'index.js'),
    (Join-Path $PSScriptRoot 'README.md')
) -DestinationPath $zipPath -Force

$b64 = [Convert]::ToBase64String([IO.File]::ReadAllBytes($zipPath))
$payload = for ($i = 0; $i -lt $b64.Length; $i += 200) {
    '#D#' + $b64.Substring($i, [Math]::Min(200, $b64.Length - $i))
}

$lines = Get-Content -LiteralPath $batPath
$head = New-Object System.Collections.Generic.List[string]
$found = $false
foreach ($l in $lines) {
    $head.Add($l)
    if ($l.StartsWith($marker)) { $found = $true; break }
}
if (-not $found) { throw 'payload marker line not found in setup-mobile.bat' }

[IO.File]::WriteAllLines($batPath, ($head + $payload))
Write-Host ("repacked setup-mobile.bat: {0} payload lines, zip {1} bytes" -f $payload.Count, (Get-Item $zipPath).Length)
