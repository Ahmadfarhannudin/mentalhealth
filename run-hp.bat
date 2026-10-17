@echo off
setlocal
cd /d "D:\project android\mentalhealth"

echo Menjalankan aplikasi Mental Health ke HP Infinix...

set "DEVICE="
for /f "tokens=1" %%D in ('adb devices ^| findstr "_adb-tls-connect._tcp" ^| findstr /R /C:"device$"') do set "DEVICE=%%D"

if not defined DEVICE (
    echo HP tidak terhubung melalui ADB wireless.
    echo Jalankan: adb devices
    adb devices
    pause
    exit /b 1
)

echo Device: %DEVICE%
flutter run -d "%DEVICE%"
if errorlevel 1 (
    echo.
    echo Flutter run gagal. Periksa koneksi ADB dan pesan error di atas.
    pause
    exit /b 1
)

endlocal
pause
