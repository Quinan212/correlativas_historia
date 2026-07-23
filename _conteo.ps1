$files = @(
    "C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\MESAS-DE-JULIO- 2026__.xlsx - Google Drive_files\sheet.html",
    "C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\1_files\sheet.html",
    "C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\323_files\sheet.html"
)
$names = @("PRIMER LLAMADO","SEGUNDO LLAMADO","COLOQUIOS")

Write-Host "=== CONTEO ACTA EN SPREADSHEET ==="
for ($i = 0; $i -lt 3; $i++) {
    $content = Get-Content $files[$i] -Raw
    $marcas = [regex]::Matches($content, "ACTA").Count
    Write-Host "$($names[$i]): $marcas marcas ACTA"
}

$AnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRybHV5YnRqdm1uZ2dsZXFjYmdmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzUyNDE3NTMsImV4cCI6MjA5MDgxNzc1M30.QgSe50OfKOhVfRn_gVMrX6ByFkX6yLtAuIvhzAN7Khk"
$headers = @{ apikey = $AnonKey; Authorization = "Bearer $AnonKey" }
$r = Invoke-RestMethod -Uri "https://drluybtjvmnggleqcbgf.supabase.co/rest/v1/exam_events?select=acta_url,instancia,legacy&legacy=eq.false" -Headers $headers -Method Get

Write-Host ""
Write-Host "=== CONTEO ACTA EN SUPABASE ==="
$conActa = $r | Where-Object { $_.acta_url -ne $null -and $_.acta_url -ne "" }
Write-Host "Total con acta_url en Supabase: $($conActa.Count)"
$conActa | Group-Object instancia | ForEach-Object { Write-Host "  $($_.Name): $($_.Count)" }

Write-Host ""
Write-Host "=== DIFERENCIAS ==="
$totalSheet = 0
for ($i = 0; $i -lt 3; $i++) {
    $content = Get-Content $files[$i] -Raw
    $marcas = [regex]::Matches($content, "ACTA").Count
    $instancia = if ($i -eq 0) { "llamado_1" } elseif ($i -eq 1) { "llamado_2" } else { "coloquio" }
    $dbCount = ($conActa | Where-Object { $_.instancia -eq $instancia }).Count
    $diff = $marcas - $dbCount
    Write-Host "$($names[$i]): Sheet=$marcas | Supabase=$dbCount | Diferencia=$diff"
    $totalSheet += $marcas
}
Write-Host "TOTAL: Sheet=$totalSheet | Supabase=$($conActa.Count) | Diferencia=$($totalSheet - $conActa.Count)"

Remove-Item "$PSScriptRoot\_conteo.ps1"
