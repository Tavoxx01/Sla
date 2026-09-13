@echo off
setlocal EnableExtensions
title Cloud PC - AnyDesk

echo ==========================================
echo          INICIANDO ANYDESK
echo ==========================================
echo.

set "ANYDESK="

for /f "delims=" %%A in ('where AnyDesk.exe 2^>nul') do (
    set "ANYDESK=%%A"
    goto FOUND
)

for /f "delims=" %%A in ('powershell -NoProfile -Command "Get-ChildItem 'C:\ProgramData\chocolatey\lib' -Recurse -Filter 'AnyDesk.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName"') do (
    set "ANYDESK=%%A"
    goto FOUND
)

for /f "delims=" %%A in ('powershell -NoProfile -Command "Get-ChildItem 'C:\Program Files','C:\Program Files (x86)' -Recurse -Filter 'AnyDesk.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName"') do (
    set "ANYDESK=%%A"
    goto FOUND
)

echo ERRO: AnyDesk.exe nao foi encontrado.
exit /b 1

:FOUND

echo AnyDesk encontrado:
echo %ANYDESK%
echo.

echo Iniciando AnyDesk...
start "" "%ANYDESK%"

timeout /t 8 /nobreak >nul

echo.
echo Verificando processo...

tasklist /FI "IMAGENAME eq AnyDesk.exe" | find /I "AnyDesk.exe" >nul

if errorlevel 1 (
    echo ERRO: AnyDesk nao esta executando.
    exit /b 1
)

echo AnyDesk esta executando.
echo.

echo Obtendo ID...

set "ID="

for /f "delims=" %%A in ('"%ANYDESK%" --get-id 2^>nul') do (
    set "ID=%%A"
)

if not defined ID (
    echo ERRO: Nao foi possivel obter o ID do AnyDesk.
    exit /b 1
)

if "%ID%"=="0" (
    echo ERRO: O AnyDesk retornou ID 0.
    exit /b 1
)

echo.
echo ==========================================
echo          ANYDESK PRONTO
echo ==========================================
echo.
echo ID: %ID%
echo.
echo ==========================================

endlocal
exit /b 0
