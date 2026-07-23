function Get-Rows {
    param($Path, $Instancia)
    $content = Get-Content $Path -Raw
    # Find rows with ACTA links
    $rows = [regex]::Matches($content, '<tr[^>]*>.*?</tr>')
    $entries = @()
    foreach ($row in $rows) {
        if ($row.Value -match '<a[^>]*>ACTA</a>') {
            # Extract cells
            $cells = [regex]::Matches($row.Value, '<td[^>]*>(.*?)</td>')
            $vals = @()
            foreach ($cell in $cells) {
                $text = $cell.Groups[1].Value -replace '<[^>]+>', ''
                $text = $text.Trim()
                $vals += $text
            }
            if ($vals.Count -ge 5) {
                $fecha = $vals[1]  # date
                $hora = $vals[2]   # time
                $carreraRaw = $vals[3]  # career
                $anioTexto = $vals[4]   # year
                $materia = ""
                # materia could be in vals[5] or could span multiple cols
                for ($j = 5; $j -lt $vals.Count - 2; $j++) {
                    if ($vals[$j] -ne "" -and $vals[$j] -notmatch '^[A-ZÁÉÍÓÚÑ ]+,' -and $j -le 6) {
                        $materia = $vals[$j]
                    }
                }
                # docentes is second to last non-empty before ACTA
                $docentes = ""
                for ($j = $vals.Count - 3; $j -ge 0; $j--) {
                    if ($vals[$j] -match ',' -and $vals[$j] -notmatch '^\d') { $docentes = $vals[$j]; break }
                }
                
                $carrera = ""
                if ($carreraRaw -match 'Historia') { $carrera = "historia" }
                elseif ($carreraRaw -match 'Geografía') { $carrera = "geografia" }
                elseif ($carreraRaw -match 'Política|Política') { $carrera = "politica" }
                
                $anio = 0
                if ($anioTexto -match '(\d)') { $anio = [int]$Matches[1] }
                
                if ($materia -ne "") {
                    $entries += [PSCustomObject]@{
                        Fecha = $fecha
                        Carrera = $carrera
                        Anio = $anio
                        Materia = $materia
                        Instancia = $Instancia
                    }
                }
            }
        }
    }
    return $entries
}

$AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybHV5YnRqdm1uZ2dsZXFjYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyNDE3NTMsImV4cCI6MjA5MDgxNzc1M30.QgSe50OfKOhVfRn_gVMrX6ByFkX6yLtAuIvhzAN7Khk"
$headers = @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
$dbUrl = "https://drluybtjvmnggleqcbgf.supabase.co/rest/v1/exam_events"
$r = Invoke-RestMethod -Uri "$dbUrl`?select=materia,instancia,fecha,anio,career_id,acta_url&legacy=eq.false" -Headers $headers -Method Get
$conActaDB = $r | Where-Object { $_.acta_url -ne $null -and $_.acta_url -ne "" }

$paths = @(
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\MESAS-DE-JULIO- 2026__.xlsx - Google Drive_files\sheet.html"; Instancia="llamado_1"},
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\1_files\sheet.html"; Instancia="llamado_2"},
    @{Path="C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\323_files\sheet.html"; Instancia="coloquio"}
)

$todasSheet = @()
$paths | ForEach-Object { $todasSheet += Get-Rows $_.Path $_.Instancia }

Write-Host "=== ACTAS EN SHEET QUE FALTAN EN SUPABASE ==="
Write-Host ""

$faltantes = @()
foreach ($entry in $todasSheet) {
    $fechaClean = $entry.Fecha
    $match = $conActaDB | Where-Object {
        $_.materia -eq $entry.Materia -and
        $_.career_id -eq $entry.Carrera -and
        $_.instancia -eq $entry.Instancia
    }
    if ($match -eq $null -or ($match.acta_url -eq $null -or $match.acta_url -eq "")) {
        $faltantes += $entry
    }
}

$faltantes | Group-Object Fecha, Instancia | Sort-Object Name | ForEach-Object {
    $fecha = $_.Name
    Write-Host "--- $fecha ---"
    $_.Group | ForEach-Object { Write-Host "  $($_.Materia) | $($_.Carrera) | anio=$($_.Anio)" }
    Write-Host ""
}

Write-Host "TOTAL FALTANTES: $($faltantes.Count)"

Remove-Item "$PSScriptRoot\_faltantes.ps1"
