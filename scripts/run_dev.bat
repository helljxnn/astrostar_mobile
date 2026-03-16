@echo off
setlocal enabledelayedexpansion

REM Uso: scripts\run_dev.bat [dispositivo|emulador|web] [IP_OPCIONAL]

set MODE=%1
if "%MODE%"=="" set MODE=dispositivo
set MANUAL_IP=%2

echo.
echo AstroStar Mobile - Desarrollo
echo.

if /I "%MODE%"=="dispositivo" goto dispositivo
if /I "%MODE%"=="device" goto dispositivo
if /I "%MODE%"=="emulador" goto emulador
if /I "%MODE%"=="emulator" goto emulador
if /I "%MODE%"=="web" goto web

echo Modo no reconocido: %MODE%
echo Uso: scripts\run_dev.bat [dispositivo^|emulador^|web] [IP_OPCIONAL]
exit /b 1

:dispositivo
REM Opcion 1 (preferida): tunel USB con ADB, evita depender de IP o red.
adb get-state >nul 2>&1
if %errorlevel%==0 (
  adb reverse tcp:4000 tcp:4000 >nul 2>&1
  if %errorlevel%==0 (
    echo Dispositivo ADB detectado. Usando tunel USB en 127.0.0.1:4000
    flutter run --dart-define=API_URL=http://127.0.0.1:4000/api
    goto end
  )
)

REM Opcion 2: red local por IP (si no hay ADB)
if not "%MANUAL_IP%"=="" (
  set LOCAL_IP=%MANUAL_IP%
  goto ip_ready
)

for /f "usebackq delims=" %%i in (`powershell -NoProfile -Command "(Get-NetIPConfiguration ^| Where-Object { $_.IPv4DefaultGateway -ne $null -and $_.NetAdapter.Status -eq 'Up' } ^| Select-Object -First 1 -ExpandProperty IPv4Address).IPAddress"`) do (
  set LOCAL_IP=%%i
)

if "%LOCAL_IP%"=="" (
  for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /R /C:"IPv4.*:"') do (
    set LOCAL_IP=%%a
    set LOCAL_IP=!LOCAL_IP: =!
    goto ip_ready
  )
)

:ip_ready
if "%LOCAL_IP%"=="" (
  echo No se pudo detectar la IP local automaticamente.
  echo Ejecuta: scripts\run_dev.bat dispositivo TU_IP
  exit /b 1
)

echo Usando red local en http://%LOCAL_IP%:4000/api
flutter run --dart-define=API_URL=http://%LOCAL_IP%:4000/api
goto end

:emulador
echo Ejecutando en emulador Android...
flutter run --dart-define=API_URL=http://10.0.2.2:4000/api
goto end

:web
echo Ejecutando en navegador...
flutter run -d chrome --dart-define=API_URL=http://localhost:4000/api
goto end

:end
endlocal
