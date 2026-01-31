@echo off
setlocal enabledelayedexpansion

:: Habit Tracker - Local Build & Test Script for Windows
:: ======================================================

echo ============================================
echo   Habit Tracker - Local Build ^& Test
echo ============================================
echo.

:: Check command line argument
if "%1"=="" goto :menu
if "%1"=="docker" goto :docker_start
if "%1"=="docker-stop" goto :docker_stop
if "%1"=="backend" goto :backend_run
if "%1"=="backend-test" goto :backend_test
if "%1"=="flutter" goto :flutter_run
if "%1"=="flutter-test" goto :flutter_test
if "%1"=="setup" goto :setup
if "%1"=="all" goto :all
goto :menu

:menu
echo Choose an option:
echo   1. setup         - Initial setup (copy env files)
echo   2. docker        - Start all services with Docker Compose
echo   3. docker-stop   - Stop all Docker services
echo   4. backend       - Run Go backend locally
echo   5. backend-test  - Run backend tests
echo   6. flutter       - Run Flutter app
echo   7. flutter-test  - Run Flutter tests
echo   8. all           - Run full test suite
echo.
echo Usage: build-local.bat [option]
echo Example: build-local.bat docker
echo.
goto :eof

:setup
echo [SETUP] Creating environment files...
echo.

:: Copy root .env file
if not exist ".env" (
    if exist ".env.example" (
        copy ".env.example" ".env"
        echo Created .env from .env.example
    ) else (
        echo WARNING: .env.example not found in root directory
    )
) else (
    echo .env already exists, skipping...
)

:: Copy backend .env file
if not exist "backend\.env" (
    if exist "backend\.env.example" (
        copy "backend\.env.example" "backend\.env"
        echo Created backend\.env from backend\.env.example
    ) else (
        echo WARNING: backend\.env.example not found
    )
) else (
    echo backend\.env already exists, skipping...
)

echo.
echo [SETUP] Done! Please edit .env files with your configuration.
echo Important: Update FIREBASE_PROJECT_ID, JWT_SECRET, and GEMINI_API_KEY
goto :eof

:docker_start
echo [DOCKER] Starting services with Docker Compose...
echo.

:: Check if Docker is running
docker info >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker is not running. Please start Docker Desktop first.
    exit /b 1
)

:: Check if .env exists
if not exist ".env" (
    echo WARNING: .env file not found. Running setup first...
    call :setup
)

:: Start Docker Compose (without nginx for development)
echo Starting PostgreSQL, Redis, and Backend...
docker-compose up -d postgres redis backend

echo.
echo [DOCKER] Waiting for services to be healthy...
timeout /t 10 /nobreak >nul

:: Check service status
docker-compose ps

echo.
echo [DOCKER] Services started!
echo   - PostgreSQL: localhost:5432
echo   - Redis:      localhost:6379
echo   - Backend:    http://localhost:8080
echo.
echo API Health Check: http://localhost:8080/api/v1/health
goto :eof

:docker_stop
echo [DOCKER] Stopping all services...
docker-compose down
echo [DOCKER] All services stopped.
goto :eof

:backend_run
echo [BACKEND] Running Go backend locally...
echo.

:: Check if Go is installed
where go >nul 2>&1
if errorlevel 1 (
    echo ERROR: Go is not installed. Please install Go 1.21+
    exit /b 1
)

cd backend

:: Download dependencies
echo Downloading Go dependencies...
go mod download

:: Run the server
echo Starting backend server...
go run cmd/server/main.go

cd ..
goto :eof

:backend_test
echo [BACKEND] Running Go backend tests...
echo.

:: Check if Go is installed
where go >nul 2>&1
if errorlevel 1 (
    echo ERROR: Go is not installed. Please install Go 1.21+
    exit /b 1
)

cd backend

:: Run tests with verbose output
echo Running tests...
go test -v ./...

if errorlevel 1 (
    echo.
    echo [BACKEND] Some tests failed!
    cd ..
    exit /b 1
) else (
    echo.
    echo [BACKEND] All tests passed!
)

cd ..
goto :eof

:flutter_run
echo [FLUTTER] Running Flutter app...
echo.

:: Check if Flutter is installed
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed. Please install Flutter 3.16+
    exit /b 1
)

cd app

:: Get dependencies
echo Getting Flutter dependencies...
flutter pub get

:: Run the app
echo Starting Flutter app...
flutter run

cd ..
goto :eof

:flutter_test
echo [FLUTTER] Running Flutter tests...
echo.

:: Check if Flutter is installed
where flutter >nul 2>&1
if errorlevel 1 (
    echo ERROR: Flutter is not installed. Please install Flutter 3.16+
    exit /b 1
)

cd app

:: Get dependencies
flutter pub get

:: Run tests
echo Running Flutter tests...
flutter test

:: Run analyzer
echo.
echo Running Flutter analyzer...
flutter analyze

if errorlevel 1 (
    echo.
    echo [FLUTTER] Some tests or analysis failed!
    cd ..
    exit /b 1
) else (
    echo.
    echo [FLUTTER] All tests passed!
)

cd ..
goto :eof

:all
echo [ALL] Running full test suite...
echo.

:: Backend tests
call :backend_test
if errorlevel 1 (
    echo Full test suite failed at backend tests.
    exit /b 1
)

:: Flutter tests
call :flutter_test
if errorlevel 1 (
    echo Full test suite failed at Flutter tests.
    exit /b 1
)

echo.
echo ============================================
echo   All tests passed successfully!
echo ============================================
goto :eof
