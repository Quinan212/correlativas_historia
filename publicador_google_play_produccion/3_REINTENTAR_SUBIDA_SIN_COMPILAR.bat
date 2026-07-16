@echo off
setlocal
chcp 65001 >nul
pushd "%~dp0"
echo =========================================================
echo  REINTENTO DE SUBIDA A PRODUCCION SIN RECOMPILAR
 echo Paquete: ar.maillet.correlativas_historia
 echo AAB: build\app\outputs\bundle\release\app-release.aab
 echo =========================================================
echo.
powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%~dp0COMPILAR_Y_SUBIR_PLAY.ps1" -ProjectPath "%~dp0.." -SoloSubir -AabPath "%~dp0..\build\app\outputs\bundle\release\app-release.aab"
set "EXITCODE=%ERRORLEVEL%"
echo.
if not "%EXITCODE%"=="0" (
  echo El reintento de publicacion termino con error %EXITCODE%.
) else (
  echo Publicacion enviada correctamente.
)
pause
popd
exit /b %EXITCODE%
