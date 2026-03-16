@echo off
REM Script para ejecutar la app en modo desarrollo (Windows)
REM Uso: scripts\run_dev.bat [dispositivo|emulador|web]

echo.
echo 🚀 AstroStar Mobile - Desarrollo
echo.

REM Detectar IP local automáticamente
for /f "tokens=2 delims=:" %%a in ('ipconfig ^| findstr /c:"IPv4"') do set LOCAL_IP=%%a
set LOCAL_IP=%LOCAL_IP:~1%

echo 📡 IP Local detectada: %LOCAL_IP%
echo.

REM Determinar modo de ejecución
set MODE=%1
if "%MODE%"=="" set MODE=dispositivo

if "%MODE%"=="dispositivo" goto dispositivo
if "%MODE%"=="device" goto dispositivo
if "%MODE%"=="emulador" goto emulador
if "%MODE%"=="emulator" goto emulador
if "%MODE%"=="web" goto web

echo ❌ Modo no reconocido: %MODE%
echo Uso: scripts\run_dev.bat [dispositivo^|emulador^|web]
exit /b 1

:dispositivo
echo 📱 Ejecutando en dispositivo físico...
flutter run --dart-define=API_URL=http://%LOCAL_IP%:4000/api
goto end

:emulador
echo 🤖 Ejecutando en emulador Android...
flutter run --dart-define=API_URL=http://10.0.2.2:4000/api
goto end

:web
echo 🌐 Ejecutando en navegador...
flutter run -d chrome --dart-define=API_URL=http://localhost:4000/api
goto end

:end
