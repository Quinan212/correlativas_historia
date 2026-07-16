@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0CONFIGURAR_PLAY_API.ps1" -PackageName "ar.maillet.correlativas_historia" -ServiceAccountJson "C:\Users\alanm\Desktop\Credenciales\google-play-correlativas.json" -Track "production" -ReleaseStatus "completed"
set EXITCODE=%ERRORLEVEL%
echo.
if not "%EXITCODE%"=="0" (
  echo La configuracion termino con error %EXITCODE%.
) else (
  echo Configuracion de PRODUCCION terminada correctamente.
)
pause
exit /b %EXITCODE%
