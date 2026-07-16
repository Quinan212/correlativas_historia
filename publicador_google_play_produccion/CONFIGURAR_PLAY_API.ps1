[CmdletBinding()]
param(
    [string]$PackageName = "ar.maillet.correlativas_historia",
    [string]$ServiceAccountJson = "C:\Users\alanm\Desktop\Credenciales\google-play-correlativas.json",
    [string]$Track = "production",
    [ValidateSet("draft", "inProgress", "halted", "completed")]
    [string]$ReleaseStatus = "completed"
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ToolDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VenvDir = Join-Path $ToolDir ".play-publisher-venv"
$ConfigPath = Join-Path $ToolDir "play_publisher_config.json"
$RequirementsPath = Join-Path $ToolDir "requirements.txt"

function Find-PythonCommand {
    $py = Get-Command py -ErrorAction SilentlyContinue
    if ($null -ne $py) {
        return @{ Exe = $py.Source; Prefix = @("-3") }
    }

    $python = Get-Command python -ErrorAction SilentlyContinue
    if ($null -ne $python) {
        return @{ Exe = $python.Source; Prefix = @() }
    }

    throw "No se encontro Python 3. Instalalo desde python.org o Microsoft Store y volve a ejecutar este archivo."
}

Write-Host "=== Configuracion Google Play Developer API ===" -ForegroundColor Cyan
Write-Host "Paquete: $PackageName"
Write-Host "Canal: $Track"
Write-Host "Credencial prevista: $ServiceAccountJson"
Write-Host ""

if ([string]::IsNullOrWhiteSpace($PackageName)) {
    $PackageName = Read-Host "Nombre de paquete exacto"
}
if ([string]::IsNullOrWhiteSpace($PackageName)) {
    throw "El nombre de paquete es obligatorio."
}

if ([string]::IsNullOrWhiteSpace($ServiceAccountJson) -or -not (Test-Path -LiteralPath ([Environment]::ExpandEnvironmentVariables($ServiceAccountJson.Trim('"'))) -PathType Leaf)) {
    Write-Host "No se encontro el JSON en la ruta prevista." -ForegroundColor Yellow
    $ServiceAccountJson = Read-Host "Pega la ruta completa del JSON de la cuenta de servicio"
}

$ServiceAccountJson = [Environment]::ExpandEnvironmentVariables($ServiceAccountJson.Trim('"'))
if (-not (Test-Path -LiteralPath $ServiceAccountJson -PathType Leaf)) {
    throw "No existe la credencial JSON: $ServiceAccountJson"
}
$ServiceAccountJson = (Resolve-Path -LiteralPath $ServiceAccountJson).Path

if ([string]::IsNullOrWhiteSpace($Track)) {
    $Track = "production"
}

if ($PackageName.Trim() -ne "ar.maillet.correlativas_historia") {
    throw "Este publicador esta preparado exclusivamente para ar.maillet.correlativas_historia."
}
if ($Track.Trim() -ne "production") {
    throw "Este publicador esta preparado para produccion. El canal debe ser production."
}
if ($ReleaseStatus -ne "completed") {
    throw "Para publicacion directa, release_status debe ser completed."
}
if (-not (Test-Path -LiteralPath $RequirementsPath -PathType Leaf)) {
    throw "No se encontro requirements.txt en: $RequirementsPath"
}

$Python = Find-PythonCommand

if (-not (Test-Path -LiteralPath $VenvDir -PathType Container)) {
    Write-Host "Creando entorno Python local..." -ForegroundColor Yellow
    $PythonArgs = @($Python.Prefix) + @("-m", "venv", $VenvDir)
    & $Python.Exe @PythonArgs
    if ($LASTEXITCODE -ne 0) {
        throw "No se pudo crear el entorno virtual de Python."
    }
}

$VenvPython = Join-Path $VenvDir "Scripts\python.exe"
if (-not (Test-Path -LiteralPath $VenvPython -PathType Leaf)) {
    throw "El entorno virtual quedo incompleto: $VenvPython"
}

Write-Host "Instalando dependencias locales..." -ForegroundColor Yellow
& $VenvPython -m pip install --disable-pip-version-check --upgrade pip
if ($LASTEXITCODE -ne 0) {
    throw "Fallo la actualizacion de pip."
}

& $VenvPython -m pip install --disable-pip-version-check -r $RequirementsPath
if ($LASTEXITCODE -ne 0) {
    throw "Fallo la instalacion de dependencias."
}

$config = [ordered]@{
    package_name = $PackageName.Trim()
    service_account_json = $ServiceAccountJson
    track = $Track.Trim()
    release_status = $ReleaseStatus
    release_notes_language = "es-419"
    changes_in_review_behavior = "ERROR_IF_IN_REVIEW"
}

$config | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $ConfigPath -Encoding UTF8

Write-Host "Probando la conexion y los permisos..." -ForegroundColor Yellow
& $VenvPython (Join-Path $ToolDir "play_publisher.py") --config $ConfigPath check
$CheckExitCode = $LASTEXITCODE
if ($CheckExitCode -ne 0) {
    Write-Host ""
    Write-Host "La configuracion se guardo, pero Google rechazo la prueba." -ForegroundColor Red
    Write-Host "Revisa que la cuenta de servicio figure en Play Console > Usuarios y permisos," -ForegroundColor Red
    Write-Host "con acceso a ar.maillet.correlativas_historia y permiso para lanzar a produccion." -ForegroundColor Red
    exit $CheckExitCode
}

Write-Host ""
Write-Host "CONFIGURACION COMPLETADA" -ForegroundColor Green
Write-Host "La conexion con Google Play funciona correctamente." -ForegroundColor Green
Write-Host "Para publicar, ejecuta 2_COMPILAR_Y_PUBLICAR_PRODUCCION.bat" -ForegroundColor Green
