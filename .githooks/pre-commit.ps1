$ErrorActionPreference = 'Stop'

$allowlistPath = Join-Path (Get-Location) '.git-large-files-allowlist'
$maxSizeBytes = 100MB
$errors = [System.Collections.Generic.List[string]]::new()

$stagedPaths = @(git.exe diff --cached --name-only)
foreach ($relativePath in $stagedPaths) {
    $normalizedPath = $relativePath.Replace('\', '/')

    $prohibitedDirectory = $normalizedPath -like 'build/*' -or
        $normalizedPath -like '*/build/*' -or
        $normalizedPath -like '.dart_tool/*' -or
        $normalizedPath -like '*/.dart_tool/*' -or
        $normalizedPath -like '.gradle/*' -or
        $normalizedPath -like '*/.gradle/*' -or
        $normalizedPath -like 'node_modules/*' -or
        $normalizedPath -like '*/node_modules/*' -or
        $normalizedPath -like '.tmp.driveupload/*' -or
        $normalizedPath -like '*/.tmp.driveupload/*' -or
        $normalizedPath -like 'dist/*' -or
        $normalizedPath -like '*/dist/*' -or
        $normalizedPath -like 'release/*' -or
        $normalizedPath -like '*/release/*' -or
        $normalizedPath -like 'releases/*' -or
        $normalizedPath -like '*/releases/*' -or
        $normalizedPath -like '.pub/*' -or
        $normalizedPath -like '*/.pub/*' -or
        $normalizedPath -like '.cache/*' -or
        $normalizedPath -like '*/.cache/*'
    if ($prohibitedDirectory) { $errors.Add("Ruta prohibida encontrada: $relativePath") }

    $prohibitedExtension = $normalizedPath.EndsWith('.apk', [System.StringComparison]::OrdinalIgnoreCase) -or
        $normalizedPath.EndsWith('.aab', [System.StringComparison]::OrdinalIgnoreCase) -or
        $normalizedPath.EndsWith('.msix', [System.StringComparison]::OrdinalIgnoreCase) -or
        $normalizedPath.EndsWith('.zip', [System.StringComparison]::OrdinalIgnoreCase) -or
        $normalizedPath.EndsWith('.7z', [System.StringComparison]::OrdinalIgnoreCase) -or
        $normalizedPath.EndsWith('.rar', [System.StringComparison]::OrdinalIgnoreCase)
    if ($prohibitedExtension) { $errors.Add("Extensión prohibida encontrada: $relativePath") }

    $sizeText = git.exe cat-file -s ":$relativePath"
    $size = 0L
    if ([Int64]::TryParse($sizeText, [Globalization.NumberStyles]::Integer, [Globalization.CultureInfo]::InvariantCulture, [ref]$size) -and $size -gt $maxSizeBytes) {
        $allowed = Test-Path -LiteralPath $allowlistPath -PathType Leaf -and
            (@(Get-Content -LiteralPath $allowlistPath -Encoding utf8) -contains $relativePath)
        if (-not $allowed) { $errors.Add("Archivo mayor a 100 MB: $relativePath ($size bytes)") }
    }
}

# El hook se excluye para que sus nombres de patrones no parezcan secretos.
# Buscar valores literales evita falsos positivos en variables como `$AnonKey`
# o campos de dominio como `initialPassword`.
$diffText = git.exe diff --cached --unified=0 -- . ':(exclude).githooks/**'
$secretPattern = '(?i)^\+.*(password|secret|api[_-]?key)\s*[:=]\s*["''][^"'']{8,}["'']'
$secretLines = @($diffText | Select-String -Pattern $secretPattern | Where-Object { $_.Line -notmatch 'placeholder|example|tu_key|allowlist|HAS_ERRORS' } | Select-Object -First 5)
if ($secretLines.Count -gt 0) {
    $errors.Add('Posibles secretos detectados en líneas agregadas:')
    foreach ($line in $secretLines) { $errors.Add($line.Line) }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    Write-Error 'Commit bloqueado por el hook pre-commit.'
    exit 1
}

exit 0
