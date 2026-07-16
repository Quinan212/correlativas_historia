# Auditoría de higiene Git - solo lectura

$ErrorActionPreference = 'SilentlyContinue'
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)

Write-Host "=== AUDITORÍA DE HIGIENE GIT ===" -ForegroundColor Cyan
Write-Host "Proyecto: $projectRoot`n"

# 1. Tamaño del .git
$gitSize = (Get-ChildItem "$projectRoot\.git" -Recurse -Force | Measure-Object Length -Sum).Sum
Write-Host ("Tamaño de .git: {0:N2} MB" -f ($gitSize / 1MB))

# 2. count-objects
git -C $projectRoot count-objects -vH

# 3. Archivos rastreados >10MB / 50MB / 100MB
Write-Host "`n=== Archivos trackeados por tamaño ===" -ForegroundColor Yellow
$largeFiles = git -C $projectRoot ls-files --stage | ForEach-Object {
    $hash = $_.Split(' ')[1]
    $path = $_ -replace '^.*\t', ''
    $size = [long](git -C $projectRoot cat-file -s $hash 2>$null)
    if ($size -ge 10485760) {
        [PSCustomObject]@{ SizeMB = [math]::Round($size/1MB); Path = $path }
    }
} | Sort-Object SizeMB -Descending

if ($largeFiles) {
    Write-Host ">10 MB:" -ForegroundColor Yellow
    $largeFiles | Format-Table -AutoSize
} else {
    Write-Host "No hay archivos trackeados >10 MB." -ForegroundColor Green
}

# 4. Rutas prohibidas trackeadas
$prohibited = @('build', '.dart_tool', '.gradle', 'node_modules', '.tmp.driveupload', 'releases', 'dist')
Write-Host "`n=== Rutas prohibidas trackeadas ===" -ForegroundColor Yellow
$found = $false
foreach ($p in $prohibited) {
    $matches = git -C $projectRoot ls-files | Select-String -Pattern $p
    if ($matches) {
        $found = $true
        Write-Host "⚠ $p encontrado:" -ForegroundColor Red
        $matches | ForEach-Object { Write-Host "  $_" }
    }
}
if (-not $found) { Write-Host "Ninguna ruta prohibida trackeada." -ForegroundColor Green }

# 5. Archivos temporales en .git/objects
$tmpPacks = Get-ChildItem "$projectRoot\.git\objects\pack\tmp_pack_*" -File -Force -ErrorAction SilentlyContinue
if ($tmpPacks) {
    $tmpSize = ($tmpPacks | Measure-Object Length -Sum).Sum
    Write-Host "`n⚠ Archivos tmp_pack_* encontrados: $($tmpPacks.Count) archivos, $([math]::Round($tmpSize/1GB,2)) GB" -ForegroundColor Red
} else {
    Write-Host "`nNo hay archivos tmp_pack_*." -ForegroundColor Green
}

Write-Host "`n=== FIN DE AUDITORÍA ===" -ForegroundColor Cyan
