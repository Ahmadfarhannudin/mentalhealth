@echo off
setlocal EnableExtensions EnableDelayedExpansion
cd /d "D:\project android\mentalhealth"

echo Menjalankan aplikasi Mental Health ke HP Infinix...

adb start-server >nul 2>&1
set "DEVICE="
set "ADDRESS="

rem ADB wireless address may change after reboot; resolve the saved device via mDNS.
for /f "tokens=1,3" %%A in ('adb mdns services 2^>nul ^| findstr /C:"adb-133157048X014915-PE8A2C"') do (
    set "ADDRESS=%%B"
)

if defined ADDRESS (
    echo Menyambungkan ulang ke HP: !ADDRESS!
    adb connect !ADDRESS!
)

rem Connected wireless devices use IP:port serials, not the mDNS service name.
for /f "tokens=1,2" %%A in ('adb devices ^| findstr /R /C:":.*device$"') do (
    if "%%B"=="device" set "DEVICE=%%A"
)

if not defined DEVICE (
    echo HP belum terhubung. Pastikan Wireless debugging aktif dan HP berada di jaringan Wi-Fi yang sama.
    echo Periksa: adb mdns services
    adb devices
    pause
    exit /b 1
)

echo Device: !DEVICE!
flutter run -d "!DEVICE!"
if errorlevel 1 (
    echo.
    echo Flutter run gagal. Periksa koneksi ADB dan pesan error di atas.
    pause
    exit /b 1
)

endlocal
pause
