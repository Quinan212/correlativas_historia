function Normalize-Name {
    param($Name)
    $result = $Name
    # Fix encoding issues from Excel HTML
    $replacements = @{
        'Ã¡' = 'á'; 'Ã©' = 'é'; 'Ã­' = 'í'; 'Ã³' = 'ó'; 'Ãº' = 'ú'
        'Ã±' = 'ñ'; 'Ã¼' = 'ü'; 'Ã\u0081' = 'Á'; 'Ã‰' = 'É'; 'Ã?' = 'Í'
        'Ã“' = 'Ó'; 'Ãš' = 'Ú'; 'Ã‘' = 'Ñ'; 'Âº' = 'º'; 'Â°' = '°'
        'â€™' = "'"; 'â€“' = '-'; 'Ã¼' = 'ü'; 'Ã§' = 'ç'
        'Ã ' = 'í '; 'Ã¡' = 'á'; 'Ã³' = 'ó'
        'Â ' = ''
        '\b1Âº AÃ±o\b' = '1º Año'
        '\b2Âº AÃ±o\b' = '2º Año'
        '\b3Âº AÃ±o\b' = '3º Año'
        '\b4Âº AÃ±o\b' = '4º Año'
    }
    foreach ($key in $replacements.Keys) {
        $result = $result -replace $key, $replacements[$key]
    }
    return $result.Trim()
}

function Get-SheetACTAEntries {
    param($Path, $Instancia)
    $content = Get-Content $Path -Raw
    $rowMatches = [regex]::Matches($content, '<tr[^>]*>.*?<a[^>]*>ACTA</a>.*?</tr>')
    $entries = @()
    
    foreach ($row in $rowMatches) {
        $rowHtml = $row.Value
        
        # Extract URL
        $urlMatch = [regex]::Match($rowHtml, 'href="[^"]*google[^"]*document/d/([^/]+)')
        $docId = if ($urlMatch.Success) { $urlMatch.Groups[1].Value } else { $null }
        if (-not $docId) { continue }
        
        # Build full URL
        $actaUrl = "https://docs.google.com/document/d/$docId/edit?usp=sharing"
        
        # Extract all td cells
        $tdMatches = [regex]::Matches($rowHtml, '<td[^>]*>(.*?)</td>')
        $vals = @()
        $colspanAccum = 0
        foreach ($td in $tdMatches) {
            $clean = $td.Groups[1].Value -replace '<[^>]+>', ''
            $clean = $clean.Trim()
            $vals += $clean
        }
        
        # Structure is: [rowNum], fecha, hora, carrera, anio, materia, [docentes1?], docentes, ACTA
        # Find materia (first text >4 chars that's not a date, time, carrera or anio pattern)
        $fecha = $null; $hora = $null; $carreraRaw = $null; $anioTexto = $null
        $materiaRaw = $null; $docentesRaw = $null
        
        $skipPatterns = '^\d+$|^\d{2}/\d{2}/2026$|^\d{2}[,\.]\d{2}|^(19|18|20|21)\d{2}|^1?[Â°º]\s*AÃ±o|^Profesorado'
        
        foreach ($v in $vals) {
            if ($v -match '^\d{2}/\d{2}/2026$') { $fecha = $v; continue }
            if ($v -match '^\d{2}[,\.]\d{2}') { $hora = $v; continue }
            if ($v -match '^Profesorado de') { $carreraRaw = $v; continue }
            if ($v -match '^\d.*AÃ±o|^\d.*Año|^\d.*año') { $anioTexto = $v; continue }
        }
        
        # Materia: find text that's not a number, not a date, not a docente pattern
        for ($i = 0; $i -lt $vals.Count; $i++) {
            $v = $vals[$i]
            if ($v -eq "ACTA" -or $v -eq "" -or $v -match '^\d+$') { continue }
            if ($v -match '^\d{2}/\d{2}/2026$') { continue }
            if ($v -match '^\d{2}[,\.]\d{2}') { continue }
            if ($v -match '^Profesorado de') { continue }
            if ($v -match '^\d.*AÃ±o|^\d.*Año|^\d.*año|^\d.*Â°') { continue }
            if ($v -match '^[A-ZÁÉÍÓÚÑ]+,\s') { $docentesRaw = $v; continue }
            if ($v -match '/') { # looks like docentes (has slashes)
                if ($v -match '^\d') { continue }
                $docentesRaw = $v; continue
            }
            if ($materiaRaw -eq $null) { $materiaRaw = $v }
        }
        
        # If we didn't find materia properly, try: first text >4 chars not matching any pattern
        if (-not $materiaRaw) {
            foreach ($v in $vals) {
                $cleaned = $v -replace '^[\d\sÂ°º]+', ''
                if ($cleaned.Length -gt 4 -and $cleaned -notmatch '^\d{2}/\d{2}' -and $cleaned -notmatch '^(19|20)' -and $cleaned -notmatch '^Profesorado' -and $cleaned -notmatch 'ACT') {
                    $materiaRaw = $cleaned
                    break
                }
            }
        }
        
        # Determine carrera
        $carrera = ""
        if ($carreraRaw -match 'Historia') { $carrera = "historia" }
        elseif ($carreraRaw -match 'Geograf') { $carrera = "geografia" }
        elseif ($carreraRaw -match 'Pol') { $carrera = "politica" }
        
        # If no carrera from raw, try the values
        if (-not $carrera) {
            foreach ($v in $vals) {
                if ($v -eq "Historia") { $carrera = "historia"; break }
                if ($v -eq "Geografía" -or $v -eq "GeografÃa") { $carrera = "geografia"; break }
                if ($v -eq "Ciencia Politica" -or $v -eq "Ciencia Política" -or $v -eq "Ciencia PolÃtica") { $carrera = "politica"; break }
            }
        }
        
        $materiaNorm = if ($materiaRaw) { Normalize-Name $materiaRaw } else { $null }
        
        # Skip header rows
        if ($materiaNorm -eq $null -or $materiaNorm -eq "Cronograma" -or $materiaNorm -match '^(Res\.|Profesorado|Mesa de|Coloquios)') { continue }
        
        $entries += [PSCustomObject]@{
            Instancia = $Instancia
            Fecha = $fecha
            Carrera = $carrera
            CarreraRaw = $carreraRaw
            MateriaRaw = $materiaRaw
            Materia = $materiaNorm
            DocId = $docId
            ActaUrl = $actaUrl
        }
    }
    return $entries
}

Write-Host "==============================================" 
Write-Host "MAPEO: Sheet ACTA → Supabase (solo faltantes)"
Write-Host "=============================================="
Write-Host ""

# Get all entries from sheet
$paths = @(
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\MESAS-DE-JULIO- 2026__.xlsx - Google Drive_files\sheet.html"; Instancia="llamado_1"},
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\1_files\sheet.html"; Instancia="llamado_2"},
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\323_files\sheet.html"; Instancia="coloquio"}
)

$todasSheet = @()
$paths | ForEach-Object { $todasSheet += Get-SheetACTAEntries $_.Path $_.Instancia }

Write-Host "Total entradas ACTA en sheet: $($todasSheet.Count)"
Write-Host ""

# Get Supabase data
$AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybHV5YnRqdm1uZ2dsZXFjYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyNDE3NTMsImV4cCI6MjA5MDgxNzc1M30.QgSe50OfKOhVfRn_gVMrX6ByFkX6yLtAuIvhzAN7Khk"
$headers = @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
$dbUrl = "https://drluybtjvmnggleqcbgf.supabase.co/rest/v1/exam_events"
$dbRows = Invoke-RestMethod -Uri "$dbUrl`?select=id,materia,instancia,fecha,anio,career_id,acta_url&legacy=eq.false" -Headers $headers -Method Get

Write-Host "Mesas en Supabase (no legacy): $($dbRows.Count)"
Write-Host "Mesas SIN acta_url: $(($dbRows | Where-Object { -not $_.acta_url }).Count)"
Write-Host ""

# Normalize materia names in DB for matching
function Normalize-Materia {
    param($Name)
    if (-not $Name) { return "" }
    $n = $Name.Trim()
    $n = $n -replace '\s+', ' '
    # Remove [SUSPENDIDA] etc prefixes
    $n = $n -replace '^\[(SUSPENDIDA|SUSPENDIDO|CANCELADA|CANCELADO|REPROGRAMADA|REPROGRAMADO)\]\s*', ''
    return $n.Trim()
}

$dbRowMap = @{}
foreach ($row in $dbRows) {
    $key = "$($row.instancia)|$(Normalize-Materia $row.materia)|$($row.career_id)"
    if ($row.fecha) { $key += "|$($row.fecha)" }
    if (-not $dbRowMap.ContainsKey($key)) {
        $dbRowMap[$key] = @()
    }
    $dbRowMap[$key] += $row
}

# Find matches
Write-Host "=== MATCHES PARA ACTUALIZAR (dry-run) ==="
Write-Host ""

$matches = @()
$unmatched = @()

foreach ($entry in $todasSheet) {
    $materiaKey = Normalize-Materia $entry.Materia
    
    # Build search keys
    $keys = @()
    if ($entry.Fecha -and $entry.Fecha -ne "") {
        $keys += "$($entry.Instancia)|$materiaKey|$($entry.Carrera)|$($entry.Fecha)"
        $keys += "$($entry.Instancia)|$materiaKey|$($entry.Carrera)"
    } else {
        $keys += "$($entry.Instancia)|$materiaKey|$($entry.Carrera)"
        $keys += "$($entry.Instancia)|$materiaKey|"
    }
    
    $matched = $null
    foreach ($k in $keys) {
        if ($dbRowMap.ContainsKey($k)) {
            $candidates = $dbRowMap[$k] | Where-Object { -not $_.acta_url }
            if ($candidates.Count -gt 0) {
                $matched = $candidates[0]
                break
            }
        }
    }
    
    if ($matched) {
        $matches += [PSCustomObject]@{
            Instancia = $entry.Instancia
            Fecha = $entry.Fecha
            Carrera = $entry.Carrera
            Materia = $materiaKey
            SupabaseId = $matched.id
            DocId = $entry.DocId
            DocUrl = $entry.ActaUrl
        }
    } else {
        $unmatched += $entry
    }
}

# Group by instancia
$matches | Group-Object Instancia | ForEach-Object {
    $group = $_.Group
    Write-Host "--- $($_.Name) ($($group.Count) matches) ---"
    $group | ForEach-Object { 
        Write-Host "  $($_.Fecha) | $($_.Carrera) | $($_.Materia)"
        Write-Host "    ID: $($_.SupabaseId)"
        Write-Host "    DocID: $($_.DocId)"
        Write-Host ""
    }
}

Write-Host "=== RESUMEN ==="
Write-Host "Total ACTA en sheet: $($todasSheet.Count)"
Write-Host "Matched (para actualizar): $($matches.Count)"
Write-Host "Sin match en Supabase: $($unmatched.Count)"
if ($unmatched.Count -gt 0) {
    Write-Host ""
    Write-Host "--- SIN MATCH ---"
    $unmatched | ForEach-Object { 
        $fechaInfo = if ($_.Fecha) { $_.Fecha } else { "S/F" }
        Write-Host "  $fechaInfo | $($_.Carrera) | $($_.MateriaRaw) | DocID=$($_.DocId)"
    }
}

Remove-Item "$PSScriptRoot\_mapeo_actas.ps1"
