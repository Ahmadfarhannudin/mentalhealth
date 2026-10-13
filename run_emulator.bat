@echo off
title Flutter - Run Emulator

cd /d "D:\project android\mentalhealth"

echo [1/2] Launch emulator...
call flutter emulators --launch Pixel_Test

echo [2/2] Tunggu emulator boot...
:wait_loop
timeout /t 5 /nobreak >nul
adb devices | findstr "emulator-5554" | findstr "device" >nul 2>&1
if errorlevel 1 (
    echo    Masih booting...
    goto wait_loop
)
echo    Emulator online!

echo.
echo Running flutter run - hot reload aktif (tekan r untuk reload, R untuk restart)...
echo Tutup window ini untuk stop.
echo.
flutter run -d emulator-5554
