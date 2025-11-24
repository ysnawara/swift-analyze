@echo off
REM ============================================================
REM  swift-analyze Demo Script
REM  Analyzes the sample Swift project and prints a quality report.
REM  
REM  Requirements: Swift toolchain and Visual Studio Build Tools
REM ============================================================

echo.
echo  Setting up Swift environment...

REM Set up Visual Studio build tools (needed for Swift on Windows)
call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1
if %ERRORLEVEL% neq 0 (
    call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64 >nul 2>&1
)

REM Set Swift SDK root
for /f "delims=" %%i in ('dir /b /ad "C:\Users\%USERNAME%\AppData\Local\Programs\Swift\Platforms" 2^>nul') do set SWIFTVER=%%i
if defined SWIFTVER (
    set "SDKROOT=C:\Users\%USERNAME%\AppData\Local\Programs\Swift\Platforms\%SWIFTVER%\Windows.platform\Developer\SDKs\Windows.sdk"
)

echo  Building swift-analyze...
echo.

swift build 2>nul
if %ERRORLEVEL% neq 0 (
    echo.
    echo  ERROR: Build failed. Make sure Swift is installed.
    echo  Install from: https://www.swift.org/install/
    echo.
    pause
    exit /b 1
)

echo.
echo  Running analysis on test-samples...
echo.

swift run swift-analyze test-samples\sample-swift-package\Sources --recursive

echo.
echo  ============================================================
echo  Try these too:
echo.
echo    JSON output:    swift run swift-analyze test-samples\sample-swift-package\Sources --recursive --format json
echo    With threshold: swift run swift-analyze test-samples\sample-swift-package\Sources --recursive --max-complexity 3
echo  ============================================================
echo.
pause
