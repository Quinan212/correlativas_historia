param(
  [string]$ProjectRef = "drluybtjvmnggleqcbgf",
  [string]$FunctionSlug = "ask-situated-assistant",
  [string]$DeviceId = "and_61fafad37df69a7e",
  [string]$DbUrl,
  [string]$DbPassword
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$text) {
  Write-Host "`n==> $text" -ForegroundColor Cyan
}

function Write-Pass([string]$text) {
  Write-Host "PASS: $text" -ForegroundColor Green
}

function Write-Fail([string]$text) {
  Write-Host "FAIL: $text" -ForegroundColor Red
}

function Invoke-SupabaseRaw([string[]]$CmdArgs) {
  $previousErrorAction = $ErrorActionPreference
  $ErrorActionPreference = "Continue"
  try {
    $output = & supabase --agent no @CmdArgs 2>&1
  }
  finally {
    $ErrorActionPreference = $previousErrorAction
  }
  $exitCode = $LASTEXITCODE
  $text = ($output | ForEach-Object { "$_" }) -join "`n"
  if ($exitCode -ne 0 -and $text -match "Connecting to remote database") {
    Start-Sleep -Seconds 2
    $previousErrorAction = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
      $output = & supabase --agent no @CmdArgs 2>&1
    }
    finally {
      $ErrorActionPreference = $previousErrorAction
    }
    $exitCode = $LASTEXITCODE
    $text = ($output | ForEach-Object { "$_" }) -join "`n"
  }
  if ($exitCode -ne 0) {
    throw "supabase $($CmdArgs -join ' ')`n$text"
  }
  return $text
}

function Convert-FromCliJson([string]$RawText) {
  $lines = $RawText -split "`r?`n"
  $startLine = -1
  for ($i = 0; $i -lt $lines.Count; $i++) {
    $trimmed = $lines[$i].TrimStart()
    if ($trimmed.StartsWith("{") -or $trimmed.StartsWith("[")) {
      $startLine = $i
      break
    }
  }

  if ($startLine -lt 0) {
    $preview = if ($RawText.Length -gt 500) { $RawText.Substring(0, 500) } else { $RawText }
    throw "No JSON payload found in CLI output.`n---RAW PREVIEW---`n$preview"
  }

  $endLine = -1
  for ($i = $lines.Count - 1; $i -ge $startLine; $i--) {
    $trimmed = $lines[$i].TrimEnd()
    if ($trimmed.EndsWith("}") -or $trimmed.EndsWith("]")) {
      $endLine = $i
      break
    }
  }

  if ($endLine -lt $startLine) {
    throw "Malformed JSON payload in CLI output."
  }

  $json = ($lines[$startLine..$endLine] -join "`n")
  return $json | ConvertFrom-Json
}

function Invoke-SupabaseJson([string[]]$CmdArgs) {
  $raw = Invoke-SupabaseRaw $CmdArgs
  return Convert-FromCliJson $raw
}

function Resolve-DbUrl {
  if ($DbUrl) {
    return $DbUrl
  }

  if (-not $DbPassword) {
    throw "Debes pasar -DbPassword o -DbUrl para ejecutar chequeos de base remota."
  }

  $poolerPath = Join-Path $PSScriptRoot "..\\supabase\\.temp\\pooler-url"
  if (-not (Test-Path $poolerPath)) {
    throw "No existe supabase/.temp/pooler-url. Ejecuta: supabase link --project-ref $ProjectRef"
  }

  $pooler = (Get-Content -Raw $poolerPath).Trim()
  if ($pooler -notmatch '^postgresql://([^@]+)@([^/]+)/postgres$') {
    throw "Formato inesperado en pooler-url: $pooler"
  }

  $user = $Matches[1]
  $hostPort = $Matches[2]
  $encodedPw = [uri]::EscapeDataString($DbPassword)
  return "postgresql://$user`:$encodedPw@$hostPort/postgres?sslmode=require"
}

function Invoke-DbQueryJson([string]$Sql) {
  for ($attempt = 1; $attempt -le 3; $attempt++) {
    try {
      $raw = Invoke-SupabaseRaw @("db", "query", $Sql, "--db-url", $script:ResolvedDbUrl, "--output", "json", "--dns-resolver", "https")
      $parsed = Convert-FromCliJson $raw
      if ($parsed -is [System.Array]) {
        return $parsed
      }
      if ($null -ne $parsed.rows) {
        return @($parsed.rows)
      }
      return @($parsed)
    }
    catch {
      if ($attempt -eq 3) {
        throw
      }
      Start-Sleep -Seconds 2
    }
  }
  throw "No se pudo ejecutar db query tras varios intentos."
}

$failures = New-Object System.Collections.Generic.List[string]

try {
  Write-Step "Verificando CLI de Supabase"
  $version = Invoke-SupabaseRaw @("--version")
  $versionLine = ($version -split "`r?`n" | Where-Object { $_ -match '\d+\.\d+\.\d+' } | Select-Object -First 1)
  if (-not $versionLine) {
    throw "No se pudo detectar version de Supabase CLI."
  }
  Write-Pass "supabase --version => $versionLine"

  Write-Step "Verificando acceso al proyecto"
  $projects = Invoke-SupabaseJson @("projects", "list", "--output", "json")
  $project = $projects | Where-Object { $_.ref -eq $ProjectRef } | Select-Object -First 1
  if (-not $project) {
    throw "No aparece el proyecto $ProjectRef en supabase projects list"
  }
  if (-not $project.linked) {
    Write-Host "WARN: el proyecto aparece pero no esta marcado como linked en esta carpeta." -ForegroundColor Yellow
  }
  Write-Pass "Proyecto accesible: $($project.name) ($($project.region))"

  Write-Step "Resolviendo DB URL para chequeos remotos"
  $script:ResolvedDbUrl = Resolve-DbUrl
  Write-Pass "DB URL lista (oculta)"

  Write-Step "Verificando migraciones locales vs remotas"
  $localVersions = Get-ChildItem (Join-Path $PSScriptRoot "..\\supabase\\migrations") -File |
    Sort-Object Name |
    ForEach-Object { ($_.BaseName -split "_", 2)[0] }

  $remoteMigrationRows = Invoke-DbQueryJson "select version from supabase_migrations.schema_migrations order by version;"
  $remoteVersions = @($remoteMigrationRows | ForEach-Object { "{0}" -f $_.version })

  $missingRemote = $localVersions | Where-Object { $_ -notin $remoteVersions }
  if ($missingRemote.Count -gt 0) {
    throw "Migraciones locales no aplicadas en remoto: $($missingRemote -join ', ')"
  }
  Write-Pass "Migraciones alineadas ($($localVersions.Count) versiones)"

  Write-Step "Chequeando corpus IA (Steiman + app sin FAQ)"
  $corpus = Invoke-DbQueryJson "select (select count(*) from public.assistant_documents) as docs, (select count(*) from public.assistant_chunks) as chunks, (select count(*) from public.assistant_chunks where lower(source_ref) like '%faq%' or lower(chunk_text) like '%lib/features/faq/%') as faq_refs;"
  $docs = [int]$corpus[0].docs
  $chunks = [int]$corpus[0].chunks
  $faqRefs = [int]$corpus[0].faq_refs

  if ($docs -lt 2) { throw "assistant_documents insuficiente: $docs" }
  if ($chunks -lt 300) { throw "assistant_chunks insuficiente: $chunks" }
  if ($faqRefs -ne 0) { throw "Se detectaron referencias FAQ en corpus: $faqRefs" }
  Write-Pass "Corpus OK (docs=$docs, chunks=$chunks, faq_refs=$faqRefs)"

  Write-Step "Chequeando hardening de tablas assistant_*"
  $hardening = Invoke-DbQueryJson "select (select count(*) from pg_indexes where schemaname='public' and indexname='assistant_chunks_chunk_text_trgm_idx') as has_trgm_idx, (select count(*) from pg_indexes where schemaname='public' and indexname='assistant_queries_status_created_idx') as has_status_idx, (select count(*) from pg_constraint where conname='assistant_documents_source_type_check') as has_source_type_check, (select count(*) from pg_constraint where conname='assistant_queries_status_check') as has_status_check;"

  foreach ($col in @('has_trgm_idx','has_status_idx','has_source_type_check','has_status_check')) {
    if ([int]$hardening[0].$col -lt 1) {
      throw "Falta control de hardening: $col"
    }
  }
  Write-Pass "Indices y constraints de hardening presentes"

  Write-Step "Chequeando function desplegada"
  $functions = Invoke-SupabaseJson @("functions", "list", "--project-ref", $ProjectRef, "--output", "json")
  $fn = $functions | Where-Object { $_.slug -eq $FunctionSlug } | Select-Object -First 1
  if (-not $fn) { throw "No existe function $FunctionSlug" }
  if ($fn.status -ne "ACTIVE") { throw "Function $FunctionSlug no esta ACTIVE (status=$($fn.status))" }
  Write-Pass "Function $FunctionSlug ACTIVE (version=$($fn.version))"

  Write-Step "Ejecutando smoke test HTTP (ok + no_evidence)"
  $apiKeys = Invoke-SupabaseJson @("projects", "api-keys", "--project-ref", $ProjectRef, "--output", "json")
  $anonLegacy = $apiKeys | Where-Object { $_.id -eq "anon" } | Select-Object -First 1
  if (-not $anonLegacy) {
    throw "No se encontro anon legacy key para smoke test."
  }

  $anonKey = $anonLegacy.api_key
  $baseUrl = "https://$ProjectRef.supabase.co/functions/v1/$FunctionSlug"
  $headers = @{
    apikey = $anonKey
    Authorization = "Bearer $anonKey"
    "Content-Type" = "application/json"
  }

  $okPayload = @{
    device_id = $DeviceId
    context_type = "materia"
    context_id = "didactica"
    question = "En nivel superior, como se fundamenta un proyecto de catedra con enfoque didactico situado?"
  } | ConvertTo-Json -Compress

  $okResponse = Invoke-RestMethod -Method Post -Uri $baseUrl -Headers $headers -Body $okPayload
  if ($okResponse.status -ne "ok") {
    throw "Respuesta esperada 'ok', vino '$($okResponse.status)'"
  }
  if (-not $okResponse.sources -or $okResponse.sources.Count -lt 1) {
    throw "Respuesta ok sin sources[]"
  }
  if ([string]::IsNullOrWhiteSpace($okResponse.answer)) {
    throw "Respuesta ok sin answer"
  }

  $noEvidencePayload = @{
    device_id = $DeviceId
    context_type = "materia"
    context_id = "didactica"
    question = "Cual es la masa de Jupiter en kilogramos exacta?"
  } | ConvertTo-Json -Compress

  $noEvidenceResponse = Invoke-RestMethod -Method Post -Uri $baseUrl -Headers $headers -Body $noEvidencePayload
  if ($noEvidenceResponse.status -ne "no_evidence") {
    throw "Respuesta esperada 'no_evidence', vino '$($noEvidenceResponse.status)'"
  }

  Write-Pass "Smoke HTTP OK (status=ok con sources y status=no_evidence)"

  Write-Step "Chequeando log de queries"
  $lastQueries = Invoke-DbQueryJson "select id, status, created_at from public.assistant_queries order by id desc limit 2;"
  if (-not $lastQueries -or $lastQueries.Count -lt 2) {
    throw "No se registraron queries recientes en assistant_queries"
  }
  Write-Pass "assistant_queries registra consultas"

  Write-Host "`nRESULTADO FINAL: TODO OK para pre-release." -ForegroundColor Green
  Write-Host "Recordatorio: antes de publicar, ejecutar release con Shorebird." -ForegroundColor Yellow
  exit 0
}
catch {
  $failures.Add($_.Exception.Message)
}

Write-Host "`nRESULTADO FINAL: FALLA pre-release." -ForegroundColor Red
$failures | ForEach-Object { Write-Fail $_ }
exit 1
