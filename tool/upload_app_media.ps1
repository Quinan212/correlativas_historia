param(
  [string]$ProjectRoot = (Split-Path -Parent $PSScriptRoot),
  [string]$ReportDirectory = 'C:\Users\alanm\Desktop\migracion_media_supabase'
)

$ErrorActionPreference = 'Stop'
$key = [Environment]::GetEnvironmentVariable('SUPABASE_SECRET_KEY')
if ([string]::IsNullOrWhiteSpace($key)) {
  throw 'Falta SUPABASE_SECRET_KEY en la sesión actual.'
}

$manifestPath = Join-Path $ReportDirectory 'media_manifest_staging.json'
if (-not (Test-Path -LiteralPath $manifestPath -PathType Leaf)) {
  throw "No existe el manifiesto: $manifestPath"
}

$baseUrl = 'https://drluybtjvmnggleqcbgf.supabase.co'
$manifestText = Get-Content -LiteralPath $manifestPath -Raw
$manifest = $manifestText | ConvertFrom-Json
$entries = @($manifest.assets.PSObject.Properties.Value)
if ($entries.Count -ne 53) {
  throw "Se esperaban 53 recursos y se encontraron $($entries.Count)."
}

$results = [System.Collections.Generic.List[object]]::new()
foreach ($entry in $entries) {
  $source = Join-Path (Join-Path $ProjectRoot 'assets') ($entry.source.Replace('/', '\'))
  if (-not (Test-Path -LiteralPath $source -PathType Leaf)) {
    throw "No existe el recurso: $source"
  }

  $item = Get-Item -LiteralPath $source
  $hash = (Get-FileHash -LiteralPath $source -Algorithm SHA256).Hash.ToLowerInvariant()
  if ($hash -ne $entry.sha256 -or $item.Length -ne [int64]$entry.size) {
    throw "El recurso cambió: $($entry.source)"
  }

  $extension = $item.Extension.ToLowerInvariant()
  $contentType = switch ($extension) {
    '.webp' { 'image/webp' }
    '.jpg' { 'image/jpeg' }
    '.jpeg' { 'image/jpeg' }
    '.mp4' { 'video/mp4' }
    default { throw "MIME no definido para $extension" }
  }

  $encoded = ($entry.path.Split('/') | ForEach-Object {
    [Uri]::EscapeDataString($_)
  }) -join '/'
  $uri = "$baseUrl/storage/v1/object/app-media/$encoded"
  $headers = @{
    apikey = $key
    Authorization = "Bearer $key"
    'x-upsert' = 'false'
    'cache-control' = 'max-age=31536000'
  }
  $response = Invoke-WebRequest -Method Post -Uri $uri -Headers $headers `
    -ContentType $contentType -InFile $source
  if ($response.StatusCode -lt 200 -or $response.StatusCode -ge 300) {
    throw "Carga fallida para $($entry.source): HTTP $($response.StatusCode)"
  }

  $head = Invoke-WebRequest -Method Head `
    -Uri "$baseUrl/storage/v1/object/public/app-media/$encoded"
  $remoteLength = [int64]$head.Headers['Content-Length']
  if ($remoteLength -ne $item.Length) {
    throw "Tamaño remoto incorrecto para $($entry.path)"
  }
  $results.Add([pscustomobject]@{
      source = $entry.source
      path = $entry.path
      size = $item.Length
      sha256 = $hash
      verifiedRemoteBytes = $remoteLength
    })
}

$manifestEncoded = 'manifests/media_manifest.json'
$manifestUri = "$baseUrl/storage/v1/object/app-media/$manifestEncoded"
$manifestHeaders = @{
  apikey = $key
  Authorization = "Bearer $key"
  'x-upsert' = 'true'
  'cache-control' = 'max-age=300'
}
Invoke-WebRequest -Method Post -Uri $manifestUri -Headers $manifestHeaders `
  -ContentType 'application/json' -Body ([Text.Encoding]::UTF8.GetBytes($manifestText)) | Out-Null

$report = [ordered]@{
  bucket = 'app-media'
  uploadedAt = (Get-Date).ToUniversalTime().ToString('o')
  assetCount = $results.Count
  assets = $results
  manifest = [ordered]@{
    path = $manifestEncoded
    bytes = [Text.Encoding]::UTF8.GetByteCount($manifestText)
    sha256 = (Get-FileHash -LiteralPath $manifestPath -Algorithm SHA256).Hash.ToLowerInvariant()
    cacheControl = 'max-age=300'
  }
}

$reportPath = Join-Path $ReportDirectory 'SUBIDA_STORAGE.json'
$report | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $reportPath -Encoding UTF8
Write-Output "Carga completada: $($results.Count) recursos. Reporte: $reportPath"
