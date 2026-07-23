function Get-SheetEntries {
    param($Path)
    $content = Get-Content $Path -Raw
    $bodyIdx = $content.IndexOf("<body")
    $tableStart = $content.IndexOf("<table", $bodyIdx)
    $tableEnd = $content.IndexOf("</table>", $tableStart) + 8
    if ($tableEnd -le 8) { $tableEnd = $content.Length }
    $tableContent = $content.Substring($tableStart, [Math]::Min($tableEnd - $tableStart, 50000))
    $regex = [regex]'>([^<]{2,})<'
    $matches = $regex.Matches($tableContent)
    $texts = $matches | ForEach-Object { $_.Groups[1].Value.Trim() } | Where-Object { $_ -ne "" }
    return $texts
}

# Parse primer llamado entries looking at the sequential structure
function Get-Entries {
    param($Texts, $Instancia)
    $entries = @()
    $i = 0
    while ($i -lt $Texts.Count) {
        if ($Texts[$i] -match '^\d{2}/\d{2}/2026$') {
            $fecha = $Texts[$i]; $i++
            $hora = if ($i -lt $Texts.Count -and $Texts[$i] -match '\d{2}[,\.]\d{2}hs?') { $Texts[$i]; $i++ } else { "" }
            # Skip until we find a carrera
            while ($i -lt $Texts.Count -and $Texts[$i] -notmatch 'Profesorado de') { $i++ }
            $carreraRaw = if ($i -lt $Texts.Count) { $Texts[$i]; $i++ } else { "" }
            $anioTexto = if ($i -lt $Texts.Count -and $Texts[$i] -match '^\d') { $Texts[$i]; $i++ } else { "" }
            $materia = if ($i -lt $Texts.Count -and $Texts[$i] -notmatch '^(ACTA|CARMAR|BARRIOS|FERNÁNDEZ|FRIGO|CODURI|VELAZQUE|MARTÍNEZ|DÍAZ|BELOTTINI|LEIVA|CAÑETE|DRI|PALAVICINI|URGATAMENDIA|GARCÍA|MOSER|LIDEBINSKY|[A-ZÁÉÍÓÚÑ ]+,)') { $Texts[$i]; $i++ } else { "" }
            # docentes
            $docentes = ""
            while ($i -lt $Texts.Count -and $Texts[$i] -notmatch '^(ACTA|\d{2}/\d{2}/2026|\d+$)') {
                $docentes += if ($docentes -eq "") { $Texts[$i] } else { " / $($Texts[$i])" }
                $i++
            }
            if ($i -lt $Texts.Count -and $Texts[$i] -eq "ACTA") { $acta = $true; $i++ } else { $acta = $false }
            
            # Determine carrera
            $carrera = ""
            if ($carreraRaw -match 'Historia') { $carrera = "historia" }
            elseif ($carreraRaw -match 'Geografía') { $carrera = "geografia" }
            elseif ($carreraRaw -match 'Política') { $carrera = "politica" }
            
            $anio = 0
            if ($anioTexto -match '(\d)') { $anio = [int]$matches[1] }
            
            if ($materia -ne "") {
                $entries += [PSCustomObject]@{
                    Fecha = $fecha
                    Carrera = $carrera
                    Anio = $anio
                    Materia = $materia
                    Instancia = $Instancia
                    Acta = $acta
                }
            }
        } else { $i++ }
    }
    return $entries
}

Write-Host "========== COMPARATIVA ACTA SHEET vs SUPABASE =========="
Write-Host ""

$AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybHV5YnRqdm1uZ2dsZXFjYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyNDE3NTMsImV4cCI6MjA5MDgxNzc1M30.QgSe50OfKOhVfRn_gVMrX6ByFkX6yLtAuIvhzAN7Khk"
$headers = @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
$dbUrl = "https://drluybtjvmnggleqcbgf.supabase.co/rest/v1/exam_events"
$rows = Invoke-RestMethod -Uri "$dbUrl`?select=materia,instancia,fecha,anio,career_id,acta_url,acta_habilitada&legacy=eq.false" -Headers $headers -Method Get

Write-Host "Mesas en Supabase con acta_url: $(($rows | Where-Object { $_.acta_url -ne $null -and $_.acta_url -ne "" }).Count)"
Write-Host ""

# Get spreadsheet entries from all 3 sheets
Write-Host "--- Discrepancias: ACTA en sheet pero SIN acta_url en Supabase ---"
Write-Host ""

$missing = @()

# Compare each entry
$toCheck = @(
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\MESAS-DE-JULIO- 2026__.xlsx - Google Drive_files\sheet.html"; Instancia="llamado_1"}
)
foreach ($s in $toCheck) {
    $texts = Get-SheetEntries $s.Path
    $i = 0
    while ($i -lt $texts.Count) {
        if ($texts[$i] -match '^\d{2}/\d{2}/2026$') {
            $fecha = $texts[$i]; $i++
            $hora = ""
            $carrera = ""; $anio = 0; $materia = ""; $acta = $false
            if ($i -lt $texts.Count -and $texts[$i] -match '\d{2}[,\.]\d{2}') { $hora = $texts[$i]; $i++ }
            # find carrera
            $carreraRaw = ""
            while ($i -lt $texts.Count -and $texts[$i] -notmatch 'Profesorado' -and $texts[$i] -notmatch '^\d{2}/\d{2}') { $i++ }
            if ($i -lt $texts.Count) { $carreraRaw = $texts[$i]; $i++ }
            # anio
            $anioTexto = ""
            if ($i -lt $texts.Count -and $texts[$i] -match '^\d') { $anioTexto = $texts[$i]; $i++ }
            # materia
            if ($i -lt $texts.Count) { $materia = $texts[$i]; $i++ }
            # skip docentes (they contain commas)
            while ($i -lt $texts.Count -and $texts[$i] -match ',' -and $texts[$i] -notmatch '^(ACTA|\d{2}/\d{2})') { $i++ }
            # ACTA mark?
            if ($i -lt $texts.Count -and $texts[$i] -eq "ACTA") { $acta = $true; $i++ }
            
            if ($carreraRaw -match 'Historia') { $carrera = "historia" }
            elseif ($carreraRaw -match 'Geografía') { $carrera = "geografia" }
            elseif ($carreraRaw -match 'Política') { $carrera = "politica" }
            if ($anioTexto -match '(\d)') { $anio = [int]$Matches[1] }
            
            if ($materia -ne "" -and $acta) {
                $matchDb = $rows | Where-Object { 
                    $_.materia -eq $materia -and $_.career_id -eq $carrera -and $_.fecha -match [regex]::Escape($fecha) -and $_.instancia -match "llamado_1"
                }
                if ($matchDb -and ($matchDb.acta_url -eq $null -or $matchDb.acta_url -eq "")) {
                    $missing += [PSCustomObject]@{Fecha=$fecha; Carrera=$carrera; Anio=$anio; Materia=$materia}
                    Write-Host "$fecha | $materia | $carrera | $anio° | MARCADA ACTA en sheet pero SIN acta_url en DB"
                }
            }
        } else { $i++ }
    }
}

Write-Host "Total discrepancias: $($missing.Count)"
Write-Host ""
Write-Host "--- Mesas con acta_url en DB que NO tienen ACTA en sheet ---"
# (reverse check would need full dataset)

Remove-Item "$PSScriptRoot\_comparativa.ps1"
