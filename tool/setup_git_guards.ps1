# Configura los hooks de Git para el proyecto
git config core.hooksPath .githooks
Write-Host "Hooks Git configurados en .githooks/"
Write-Host "core.hooksPath = $(git config --get core.hooksPath)"
