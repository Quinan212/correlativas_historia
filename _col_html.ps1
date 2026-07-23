$c = Get-Content "C:\Users\alanm\Desktop\mesas nuevas\meSAS HOY 22 DEJ ULIO\323_files\sheet.html" -Raw
$rows = [regex]::Matches($c, '<tr[^>]*>.*?</tr>')
foreach ($r in $rows) {
    if ($r.Value -match 'ACTA') {
        $docMatch = [regex]::Match($r.Value, 'document/d/([^/&?]+)')
        $docId = if ($docMatch.Success) { $docMatch.Groups[1].Value } else { "?" }
        $texts = [regex]::Matches($r.Value, '<td[^>]*>(.*?)</td>')
        $vals = @()
        $idx = 0
        foreach ($t in $texts) {
            $clean = $t.Groups[1].Value -replace '<[^>]+>', ''
            $clean = $clean.Trim()
            if ($clean -ne "" -and $clean -ne "ACTA") {
                Write-Host "  col$idx : $clean"
            }
            $idx++
        }
        Write-Host "DocID: $docId"
        Write-Host "---"
    }
}
Remove-Item "$PSScriptRoot\_col_hmtl.ps1"