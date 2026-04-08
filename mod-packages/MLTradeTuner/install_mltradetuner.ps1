param(
    [string]$GameRoot = "C:\Program Files (x86)\Steam\steamapps\common\Manor Lords",
    [switch]$DisableUE4SSGuiConsole = $true
)

$win64 = Join-Path $GameRoot 'ManorLords\Binaries\Win64'
$modsDir = Join-Path $win64 'ue4ss\Mods'
$targetMod = Join-Path $modsDir 'MLTradeTuner'
$sourceMod = Join-Path $PSScriptRoot 'MLTradeTuner'
$modsTxt = Join-Path $modsDir 'mods.txt'
$ue4ssIni = Join-Path $win64 'ue4ss\UE4SS-settings.ini'

if (-not (Test-Path -LiteralPath $modsDir)) {
    Write-Error "No se encontro UE4SS en: $modsDir`nInstala primero UE4SS (ML-UE4SS Mod Loader)."
    exit 1
}

if (-not (Test-Path -LiteralPath $sourceMod)) {
    Write-Error "No se encontro la carpeta fuente del mod: $sourceMod"
    exit 1
}

New-Item -ItemType Directory -Path $targetMod -Force | Out-Null
Copy-Item -LiteralPath $sourceMod -Destination $modsDir -Recurse -Force

if (Test-Path -LiteralPath $modsTxt) {
    $lines = Get-Content -LiteralPath $modsTxt
    $has = $false
    $new = foreach($line in $lines){
        if($line -match '^MLTradeTuner\s*:\s*[01]\s*$'){
            $has = $true
            'MLTradeTuner : 1'
        } else {
            $line
        }
    }
    if(-not $has){ $new += 'MLTradeTuner : 1' }
    Set-Content -LiteralPath $modsTxt -Value $new -Encoding ASCII
} else {
    Set-Content -LiteralPath $modsTxt -Value 'MLTradeTuner : 1' -Encoding ASCII
}

if ($DisableUE4SSGuiConsole -and (Test-Path -LiteralPath $ue4ssIni)) {
    $ini = Get-Content -LiteralPath $ue4ssIni
    $ini = $ini | ForEach-Object {
        if($_ -match '^ConsoleEnabled\s*='){ 'ConsoleEnabled = 0' }
        elseif($_ -match '^GuiConsoleEnabled\s*='){ 'GuiConsoleEnabled = 0' }
        elseif($_ -match '^GuiConsoleVisible\s*='){ 'GuiConsoleVisible = 0' }
        else { $_ }
    }
    Set-Content -LiteralPath $ue4ssIni -Value $ini -Encoding ASCII
}

Write-Output 'Instalacion completada.'
Write-Output "Mod copiado en: $targetMod"
Write-Output "mods.txt actualizado: $modsTxt"
Write-Output 'Reinicia el juego para aplicar cambios.'
