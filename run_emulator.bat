@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Flutter - Run Emulator

cd /d "D:\project android\mentalhealth"
set "EMULATOR=C:\Users\farhan\AppData\Local\Android\Sdk\emulator\emulator.exe"
set "DEVICE=emulator-5554"
set /a WAIT_COUNT=0

echo [1/2] Periksa emulator...
adb devices | findstr /R /C:"^%DEVICE%.*device$" >nul 2>&1
if not errorlevel 1 goto wait_ready

tasklist /FI "IMAGENAME eq emulator.exe" | findstr /I /C:"emulator.exe" >nul 2>&1
if not errorlevel 1 (
    echo Emulator sudah berjalan. Menunggu ADB...
    goto wait_ready
)

if not exist "%EMULATOR%" (
    echo emulator.exe tidak ditemukan:
    echo %EMULATOR%
    pause
    exit /b 1
)

echo Memulai Pixel_Test...
start "Pixel_Test" /min "%EMULATOR%" -avd Pixel_Test -no-snapshot -no-boot-anim -gpu host

echo [2/2] Tunggu Android siap (maksimal 180 detik)...
:wait_ready
ping 127.0.0.1 -n 6 >nul
set /a WAIT_COUNT+=1

adb devices | findstr /R /C:"^%DEVICE%.*device$" >nul 2>&1
if errorlevel 1 goto not_ready

adb -s %DEVICE% shell getprop sys.boot_completed 2>nul | findstr /X "1" >nul
if errorlevel 1 goto not_ready

adb -s %DEVICE% shell cmd package list packages >nul 2>&1
if not errorlevel 1 goto run_app

:not_ready
if !WAIT_COUNT! GEQ 36 goto emulator_timeout
echo    Masih booting...
goto wait_ready

:emulator_timeout
echo Emulator belum siap selepas 180 saat.
echo Tutup emulator lalu jalankan Cold Boot Now dari Android Studio Device Manager.
adb devices
pause
exit /b 1

:run_app
echo Emulator siap.
echo.
echo Menjalankan Flutter. Tekan r reload, R restart, q keluar.
echo.
flutter run -d %DEVICE%
if errorlevel 1 (
    echo.
    echo Flutter run gagal. Periksa pesan error di atas.
    pause
    exit /b 1
)
endlocal
exit /b 0
