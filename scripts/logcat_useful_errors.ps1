param(
    [string]$PackageName = "ar.maillet.correlativas_historia",
    [ValidateSet("E", "W")]
    [string]$Level = "E",
    [switch]$NoPid,
    [switch]$Raw,
    [switch]$Help
)

if ($Help) {
    Write-Host "Uso:"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\scripts\logcat_useful_errors.ps1"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\scripts\logcat_useful_errors.ps1 -Level W"
    Write-Host "  powershell -ExecutionPolicy Bypass -File .\scripts\logcat_useful_errors.ps1 -Raw"
    Write-Host ""
    Write-Host "Opciones:"
    Write-Host "  -PackageName  Application id a filtrar."
    Write-Host "  -Level        E = solo errores, W = warnings + errores."
    Write-Host "  -NoPid        No intenta atarse al PID actual."
    Write-Host "  -Raw          No filtra ruido del sistema."
    exit 0
}

$adb = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adb) {
    Write-Error "No se encontro adb en PATH."
    exit 1
}

$noisePattern = @(
    ' VRI\[',
    ' InsetsController',
    ' InsetsSourceConsumer',
    ' SurfaceView',
    ' BLASTBufferQueue',
    ' SurfaceComposerClient',
    ' FlutterJNI',
    ' Choreographer',
    '^\s*I/SV\[',
    '^\s*D/SurfaceView',
    '^\s*I/SurfaceView',
    '^\s*V/SurfaceView',
    '^\s*E/gralloc4',
    '^\s*E/Gralloc4',
    '^\s*E/GraphicBufferAllocator',
    '^\s*E/AHardwareBuffer',
    '^\s*E/Surface\s'
) -join '|'

$pid = $null
if (-not $NoPid) {
    try {
        $pid = (& adb shell pidof -s $PackageName 2>$null | Out-String).Trim()
    } catch {
        $pid = $null
    }
}

$logcatArgs = @()
if ($pid) {
    $logcatArgs += "--pid=$pid"
}
$logcatArgs += "*:$Level"

Write-Host "Package: $PackageName"
Write-Host "Level:   $Level"
if ($pid) {
    Write-Host "PID:     $pid"
} else {
    Write-Host "PID:     no encontrado, usando logcat global"
}
if ($Raw) {
    Write-Host "Filtro:  crudo"
} else {
    Write-Host "Filtro:  sin ruido de sistema/grafica"
}
Write-Host ""

if ($Raw) {
    & adb logcat @logcatArgs
    exit $LASTEXITCODE
}

& adb logcat @logcatArgs | Select-String -NotMatch $noisePattern
exit $LASTEXITCODE
