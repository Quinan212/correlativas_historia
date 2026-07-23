$path = "C:\Users\alanm\Desktop\mesas nuevas\file.pdf"
$bytes = [System.IO.File]::ReadAllBytes($path)
$text = [System.Text.Encoding]::UTF8.GetString($bytes)
$matches = [regex]::Matches($text, '\(([^\)]{3,})\)')
$matches | ForEach-Object { $_.Groups[1].Value } | Select-Object -First 50

Remove-Item "$PSScriptRoot\_pdf_extract.ps1"
