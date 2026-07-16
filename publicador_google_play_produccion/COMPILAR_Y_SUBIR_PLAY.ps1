[CmdletBinding()]
param(
    [string]$ProjectPath = ".",
    [string]$Notas = "Actualizacion automatica",
    [string]$BuildName = "",
    [string]$Flavor = "",
    [switch]$SoloSubir,
    [string]$AabPath = ""
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

$ToolDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ConfigPath = Join-Path $ToolDir "play_publisher_config.json"
$VenvPython = Join-Path $ToolDir ".play-publisher-venv\Scripts\python.exe"
$Uploader = Join-Path $ToolDir "play_publisher.py"
$LogDir = Join-Path $ToolDir "logs"
New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$LogPath = Join-Path $LogDir "publicacion-$Timestamp.log"

function Write-Step([string]$Message) {
    $line = "[$(Get-Date -Format 'HH:mm:ss')] $Message"
    Write-Host $line -ForegroundColor Cyan
    Add-Content -LiteralPath $LogPath -Value $line -Encoding UTF8
}

function Invoke-LoggedCommand {
    param(
        [Parameter(Mandatory = $true)][string]$FilePath,
        [Parameter(Mandatory = $true)][string[]]$ArgumentList
    )

    # Windows PowerShell 5.1 convierte cualquier texto escrito por un programa
    # nativo en STDERR en un NativeCommandError cuando ErrorActionPreference es
    # Stop. Flutter usa STDERR también para advertencias válidas, por ejemplo la
    # advertencia de KGP de pdfx. Durante el comando dejamos esos mensajes pasar
    # y decidimos el resultado exclusivamente por el código de salida real.
    $previousErrorActionPreference = $ErrorActionPreference
    try {
        $ErrorActionPreference = "Continue"
        & $FilePath @ArgumentList 2>&1 |
            Tee-Object -FilePath $LogPath -Append
        $exitCode = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previousErrorActionPreference
    }

    if ($exitCode -ne 0) {
        throw "El comando fallo con codigo ${exitCode}: $FilePath $($ArgumentList -join ' ')"
    }
}

if (-not (Test-Path -LiteralPath $ConfigPath -PathType Leaf)) {
    throw "Falta play_publisher_config.json. Ejecuta primero 1_CONFIGURAR_PRODUCCION.bat."
}
if (-not (Test-Path -LiteralPath $VenvPython -PathType Leaf)) {
    throw "Falta el entorno Python. Ejecuta primero 1_CONFIGURAR_PRODUCCION.bat."
}
if (-not (Test-Path -LiteralPath $Uploader -PathType Leaf)) {
    throw "Falta play_publisher.py en: $Uploader"
}

$PublisherConfig = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json
if ($PublisherConfig.package_name -ne "ar.maillet.correlativas_historia") {
    throw "Configuracion rechazada: package_name debe ser ar.maillet.correlativas_historia."
}
if ($PublisherConfig.track -ne "production") {
    throw "Configuracion rechazada: track debe ser production."
}
if ($PublisherConfig.release_status -ne "completed") {
    throw "Configuracion rechazada: release_status debe ser completed."
}

$ProjectPath = [Environment]::ExpandEnvironmentVariables($ProjectPath.Trim('"'))
$ProjectPath = (Resolve-Path -LiteralPath $ProjectPath).Path

if (-not $SoloSubir) {
    $Pubspec = Join-Path $ProjectPath "pubspec.yaml"
    if (-not (Test-Path -LiteralPath $Pubspec -PathType Leaf)) {
        throw "La ruta no parece ser un proyecto Flutter: $ProjectPath"
    }

    $Flutter = Get-Command flutter -ErrorAction SilentlyContinue
    if ($null -eq $Flutter) {
        throw "No se encontro Flutter en PATH."
    }

    $PubspecText = Get-Content -LiteralPath $Pubspec -Raw -Encoding UTF8
    $VersionMatch = [regex]::Match(
        $PubspecText,
        '(?m)^(?<prefix>\s*version\s*:\s*[^\r\n+]+)\+(?<code>\d+)(?<suffix>[^\r\n]*)$'
    )
    if (-not $VersionMatch.Success) {
        throw "No se pudo leer version: x.y.z+N en pubspec.yaml."
    }

    $CurrentBuildNumber = [int64]$VersionMatch.Groups['code'].Value
    Write-Step "Consultando el versionCode mas alto en Google Play..."
    $VersionArgs = @(
        $Uploader,
        "--config", $ConfigPath,
        "next-version-code",
        "--local-current", "$CurrentBuildNumber"
    )
    $VersionOutput = & $VenvPython @VersionArgs 2>&1
    $VersionExitCode = $LASTEXITCODE
    $VersionOutput | Tee-Object -FilePath $LogPath -Append | Out-Host
    if ($VersionExitCode -ne 0) {
        throw "No se pudo calcular el siguiente versionCode. Codigo: $VersionExitCode"
    }

    $VersionText = ($VersionOutput | ForEach-Object { [string]$_ }) -join "`n"
    $NextMatch = [regex]::Match($VersionText, '(?m)^NEXT_VERSION_CODE=(\d+)\s*$')
    if (-not $NextMatch.Success) {
        throw "La herramienta no devolvio NEXT_VERSION_CODE."
    }

    $BuildNumber = [int64]$NextMatch.Groups[1].Value
    Write-Step "Proyecto: $ProjectPath"
    Write-Step "versionCode local actual: $CurrentBuildNumber"
    Write-Step "Nuevo versionCode: $BuildNumber (incremento de 1 sobre el mayor detectado)"

    Push-Location $ProjectPath
    try {
        Write-Step "Ejecutando flutter pub get..."
        Invoke-LoggedCommand -FilePath $Flutter.Source -ArgumentList @("pub", "get")

        $BuildArgs = @("build", "appbundle", "--release", "--no-tree-shake-icons", "--build-number=$BuildNumber")
        if (-not [string]::IsNullOrWhiteSpace($BuildName)) {
            $BuildArgs += "--build-name=$BuildName"
        }
        if (-not [string]::IsNullOrWhiteSpace($Flavor)) {
            $BuildArgs += @("--flavor", $Flavor)
        }

        Write-Step "Compilando AAB firmado con tree-shake de iconos desactivado..."
        Invoke-LoggedCommand -FilePath $Flutter.Source -ArgumentList $BuildArgs

        # Mantiene pubspec.yaml sincronizado con el versionCode que acaba de compilarse.
        $CodeStart = $VersionMatch.Groups['code'].Index
        $CodeLength = $VersionMatch.Groups['code'].Length
        $UpdatedPubspec = $PubspecText.Substring(0, $CodeStart) +
            $BuildNumber +
            $PubspecText.Substring($CodeStart + $CodeLength)
        Set-Content -LiteralPath $Pubspec -Value $UpdatedPubspec -Encoding UTF8 -NoNewline
        Write-Step "pubspec.yaml actualizado a versionCode +$BuildNumber"
    }
    finally {
        Pop-Location
    }

    if ([string]::IsNullOrWhiteSpace($AabPath)) {
        if ([string]::IsNullOrWhiteSpace($Flavor)) {
            $AabPath = Join-Path $ProjectPath "build\app\outputs\bundle\release\app-release.aab"
        }
        else {
            $AabPath = Join-Path $ProjectPath "build\app\outputs\bundle\$($Flavor)Release\app-$Flavor-release.aab"
        }
    }
}

if ([string]::IsNullOrWhiteSpace($AabPath)) {
    throw "Usaste -SoloSubir pero no indicaste -AabPath."
}

$AabPath = [Environment]::ExpandEnvironmentVariables($AabPath.Trim('"'))
if (-not [System.IO.Path]::IsPathRooted($AabPath)) {
    $AabPath = Join-Path $ProjectPath $AabPath
}
if (-not (Test-Path -LiteralPath $AabPath -PathType Leaf)) {
    throw "No se encontro el AAB esperado: $AabPath"
}
$AabPath = (Resolve-Path -LiteralPath $AabPath).Path

$Aab = Get-Item -LiteralPath $AabPath
$ReleaseName = "Automatica $Timestamp"
$SizeMb = [math]::Round($Aab.Length / 1MB, 2)
Write-Step "AAB listo: $AabPath ($SizeMb MB)"
Write-Step "Enviando directamente a PRODUCCION mediante Google Play Developer API..."

Invoke-LoggedCommand -FilePath $VenvPython -ArgumentList @(
    $Uploader,
    "--config", $ConfigPath,
    "upload",
    "--aab", $AabPath,
    "--release-name", $ReleaseName,
    "--notes", $Notas
)

Write-Host ""
Write-Host "LISTO: NUEVA VERSION ENVIADA A PRODUCCION" -ForegroundColor Green
Write-Host "Log: $LogPath" -ForegroundColor Green
