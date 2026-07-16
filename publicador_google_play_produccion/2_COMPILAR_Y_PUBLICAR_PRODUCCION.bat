@echo off
setlocal
cd /d "%~dp0"
echo =========================================================
echo  PUBLICACION DIRECTA EN PRODUCCION
echo  Paquete: ar.maillet.correlativas_historia
echo =========================================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0COMPILAR_Y_SUBIR_PLAY.ps1" -ProjectPath "%~dp0.."
set EXITCODE=%ERRORLEVEL%
echo.
if not "%EXITCODE%"=="0" (
  echo La compilacion o publicacion termino con error %EXITCODE%.
  echo Revisa la carpeta logs dentro de publicador_google_play_produccion.
) else (
  echo La nueva version fue enviada al canal de PRODUCCION.
)
pause
exit /b %EXITCODE%
