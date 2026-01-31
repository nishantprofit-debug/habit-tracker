@echo off
REM ============================================
REM Habit Tracker - APK Build Script
REM ============================================

echo.
echo ========================================
echo   Habit Tracker APK Builder
echo ========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo Please install Flutter from https://flutter.dev
    pause
    exit /b 1
)

echo [1/6] Checking Flutter installation...
flutter --version
echo.

echo [2/6] Navigating to app directory...
cd app
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Could not find app directory
    pause
    exit /b 1
)
echo.

echo [3/6] Cleaning previous builds...
flutter clean
echo.

echo [4/6] Getting dependencies...
flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)
echo.

echo [5/6] Building release APK...
echo This may take a few minutes...
flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo ERROR: Failed to build APK
    pause
    exit /b 1
)
echo.

echo [6/6] Build complete!
echo.
echo ========================================
echo   APK Location:
echo   %CD%\build\app\outputs\flutter-apk\app-release.apk
echo ========================================
echo.
echo You can now install this APK on your Android device.
echo.

REM Open the output folder
start "" "%CD%\build\app\outputs\flutter-apk"

pause
