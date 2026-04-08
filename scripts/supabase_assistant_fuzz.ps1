param(
  [string]$ProjectRef = "drluybtjvmnggleqcbgf",
  [string]$FunctionSlug = "ask-situated-assistant",
  [string]$DeviceId = "fuzz_device_local",
  [int]$Iterations = 120,
  [int]$Seed = 12345,
  [double]$MaxGenericRate = 0.20,
  [switch]$Continuous,
  [int]$SleepMs = 150,
  [string]$OutFile = "RUIDO/assistant_fuzz_report.json"
)

$ErrorActionPreference = "Stop"

function Write-Step([string]$text) {
  Write-Host "`n==> $text" -ForegroundColor Cyan
}

function Write-Pass([string]$text) {
  Write-Host "PASS: $text" -ForegroundColor Green
}

function Write-Warn([string]$text) {
  Write-Host "WARN: $text" -ForegroundColor Yellow
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
    throw "No JSON payload found in CLI output."
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
  ($lines[$startLine..$endLine] -join "`n") | ConvertFrom-Json
}

function Invoke-SupabaseJson([string[]]$CmdArgs) {
  $raw = Invoke-SupabaseRaw $CmdArgs
  return Convert-FromCliJson $raw
}

function Normalize-Text([string]$value) {
  if ([string]::IsNullOrWhiteSpace($value)) { return "" }
  return ($value.ToLowerInvariant() -replace "\s+", " ").Trim()
}

function Is-GenericAnswer([string]$answer) {
  $n = Normalize-Text $answer
  if ($n.Length -eq 0) { return $true }
  if ($n -like "*desde una mirada situada, la consulta se puede encarar*") { return $true }
  if ($n -like "*conviene explicitar propositos, contenidos, criterios de evaluacion*") { return $true }
  if ($n -like "*base de evidencia: textos de la app (sin faq)*") { return $true }
  return $false
}

function Is-ClarificationAnswer([string]$answer) {
  $n = Normalize-Text $answer
  if ($n -like "*la consulta quedo incompleta*") { return $true }
  if ($n -like "*no pude ubicar la carrera*") { return $true }
  if ($n -like "*decime la materia completa*") { return $true }
  if ($n -like "*te leo, pero esa consulta quedo muy corta*") { return $true }
  return $false
}

function New-QuestionPool {
  $careers = @("historia", "geografia", "ciencia politica")
  $subjects = @(
    "didactica de la historia",
    "didactica de las ciencias sociales",
    "practica docente iii",
    "practica docente iv",
    "historia de las ideas ii",
    "sujetos de la educacion secundaria"
  )
  $shortFragments = @(
    "didactica y",
    "practica iii",
    "correlativas de didactica",
    "me abre didactica?"
  )
  $greetings = @("hola", "buenas", "que tal")

  $templates = @(
    "que materias necesito para cursar {SUBJ} en {CAR}",
    "de que año es {SUBJ} en {CAR}",
    "{SUBJ} habilita algo en {CAR}?",
    "que tipo o formato tiene {SUBJ} en {CAR}",
    "correlativas de {SUBJ} en {CAR}",
    "si regularizo {SUBJ} que me habilita en {CAR}",
    "me decis requisitos de {SUBJ} {CAR}",
    "para cursar {SUBJ} que piden en {CAR}"
  )

  $questions = New-Object System.Collections.Generic.List[string]
  foreach ($tpl in $templates) {
    foreach ($career in $careers) {
      foreach ($subj in $subjects) {
        $q = $tpl.Replace("{SUBJ}", $subj).Replace("{CAR}", $career)
        $questions.Add($q)
      }
    }
  }
  foreach ($frag in $shortFragments) { $questions.Add($frag) }
  foreach ($g in $greetings) { $questions.Add($g) }
  $questions.Add("masa de jupiter en kilogramos exacta")
  $questions.Add("como fundamentar una propuesta didactica situada")
  return $questions
}

Write-Step "Cargando anon key del proyecto"
$apiKeys = Invoke-SupabaseJson @("projects", "api-keys", "--project-ref", $ProjectRef, "--output", "json")
$anonLegacy = $apiKeys | Where-Object { $_.id -eq "anon" } | Select-Object -First 1
if (-not $anonLegacy) {
  throw "No se encontro anon legacy key para fuzz test."
}
$anonKey = $anonLegacy.api_key
$baseUrl = "https://$ProjectRef.supabase.co/functions/v1/$FunctionSlug"
$headers = @{
  apikey = $anonKey
  Authorization = "Bearer $anonKey"
  "Content-Type" = "application/json"
}

$pool = New-QuestionPool
$rnd = [System.Random]::new($Seed)
$results = New-Object System.Collections.Generic.List[object]

function Invoke-OneQuestion([string]$question, [int]$index) {
  $payload = @{
    device_id = $DeviceId
    context_type = "uso_app"
    context_id = ""
    question = $question
  } | ConvertTo-Json -Compress

  $started = Get-Date
  $status = "error"
  $answer = ""
  $sources = 0
  $err = $null
  try {
    $response = Invoke-RestMethod -Method Post -Uri $baseUrl -Headers $headers -Body $payload
    $status = [string]$response.status
    $answer = [string]$response.answer
    $sources = @($response.sources).Count
  }
  catch {
    $err = "$_"
  }
  $latencyMs = [int]((Get-Date) - $started).TotalMilliseconds
  $isGeneric = Is-GenericAnswer $answer
  $isClarification = Is-ClarificationAnswer $answer

  [pscustomobject]@{
    i = $index
    question = $question
    status = $status
    sources = $sources
    latency_ms = $latencyMs
    generic = $isGeneric
    clarification = $isClarification
    answer = $answer
    error = $err
  }
}

function Run-Batch([int]$count, [int]$offset) {
  for ($i = 0; $i -lt $count; $i++) {
    $pick = $pool[$rnd.Next(0, $pool.Count)]
    $result = Invoke-OneQuestion -question $pick -index ($offset + $i + 1)
    $results.Add($result)

    $msg = "[#$($result.i)] status=$($result.status) generic=$($result.generic) clar=$($result.clarification) src=$($result.sources) q='$($result.question)'"
    if ($result.error) {
      Write-Fail "$msg err=$($result.error)"
    }
    elseif ($result.generic) {
      Write-Warn $msg
    }
    else {
      Write-Host $msg -ForegroundColor Gray
    }
    Start-Sleep -Milliseconds $SleepMs
  }
}

Write-Step "Ejecutando fuzz test"
if ($Continuous) {
  Write-Warn "Modo continuo activo. Corta con Ctrl + C."
  $offset = 0
  while ($true) {
    Run-Batch -count $Iterations -offset $offset
    $offset += $Iterations
  }
} else {
  Run-Batch -count $Iterations -offset 0
}

$total = $results.Count
$ok = @($results | Where-Object { $_.status -eq "ok" }).Count
$noEvidence = @($results | Where-Object { $_.status -eq "no_evidence" }).Count
$err = @($results | Where-Object { $_.status -eq "error" -or $_.error }).Count
$generic = @($results | Where-Object { $_.generic }).Count
$clar = @($results | Where-Object { $_.clarification }).Count

$genericRate = if ($total -gt 0) { [math]::Round($generic / $total, 4) } else { 0.0 }
$avgLatency = if ($total -gt 0) {
  [math]::Round((($results | Measure-Object latency_ms -Average).Average), 1)
} else {
  0.0
}

$summary = [pscustomobject]@{
  generated_at = (Get-Date).ToString("s")
  project_ref = $ProjectRef
  function = $FunctionSlug
  iterations = $total
  ok = $ok
  no_evidence = $noEvidence
  errors = $err
  generic = $generic
  clarification = $clar
  generic_rate = $genericRate
  avg_latency_ms = $avgLatency
  max_generic_rate = $MaxGenericRate
}

if ($OutFile) {
  $dir = Split-Path -Path $OutFile -Parent
  if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir | Out-Null
  }
  [pscustomobject]@{
    summary = $summary
    results = $results
  } | ConvertTo-Json -Depth 8 | Set-Content -Encoding UTF8 $OutFile
  Write-Pass "Reporte guardado en $OutFile"
}

Write-Step "Resumen"
Write-Host ("total={0} ok={1} no_evidence={2} err={3} generic={4} clar={5} generic_rate={6} avg_ms={7}" -f `
    $total, $ok, $noEvidence, $err, $generic, $clar, $genericRate, $avgLatency)

if ($genericRate -gt $MaxGenericRate) {
  Write-Fail "Generic rate $genericRate supera umbral $MaxGenericRate"
  exit 1
}

Write-Pass "Generic rate dentro del umbral"
Write-Host "Recordatorio: si esta OK, la release se publica por Shorebird." -ForegroundColor Yellow
exit 0
