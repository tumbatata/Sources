@echo off
setlocal
set "QUOTE_DEMO_ROOT=%~dp0"
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -Command "Unblock-File -LiteralPath (Join-Path $env:QUOTE_DEMO_ROOT 'RunDemo.ps1'); & (Join-Path $env:QUOTE_DEMO_ROOT 'RunDemo.ps1')"
set "DEMO_EXIT=%ERRORLEVEL%"
echo.
echo Demo exit code: %DEMO_EXIT% (nonzero is expected when tests fail).
pause
exit /b %DEMO_EXIT%
