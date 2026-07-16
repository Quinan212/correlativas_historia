$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ToolDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ToolDir "play_publisher_config.json"
$Python = Join-Path $ToolDir ".play-publisher-venv\Scripts\python.exe"
$Uploader = Join-Path $ToolDir "play_publisher.py"

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Falta play_publisher_config.json. Ejecuta primero 1_CONFIGURAR_PRODUCCION.bat."
}
if (-not (Test-Path -LiteralPath $Python -PathType Leaf)) {
    throw "Falta el entorno Python. Ejecuta primero 1_CONFIGURAR_PRODUCCION.bat."
}

& $Python $Uploader --config $ConfigPath check
exit $LASTEXITCODE
