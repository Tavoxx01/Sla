@echo off
setlocal
title Cloud PC - Instalacao

echo ==========================================
echo       PREPARANDO O WINDOWS
echo ==========================================
echo.

:: Verifica se o Chocolatey existe
where choco >nul 2>&1

if errorlevel 1 (
    echo Instalando Chocolatey...
    powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"

    if errorlevel 1 (
        echo ERRO: Falha ao instalar o Chocolatey.
        exit /b 1
    )
)

call refreshenv >nul 2>&1

echo.
echo Instalando AnyDesk...
choco install anydesk -y --no-progress

if errorlevel 1 (
    echo ERRO: Falha ao instalar o AnyDesk.
    exit /b 1
)

call refreshenv >nul 2>&1

echo.
echo Verificando instalacao...

where AnyDesk.exe >nul 2>&1

if errorlevel 1 (
    echo AnyDesk nao apareceu no PATH.
    echo A instalacao pode ter sido concluida, mas o executavel sera localizado pelo start.bat.
) else (
    echo AnyDesk encontrado no PATH.
)

echo.
echo ==========================================
echo       INSTALACAO CONCLUIDA
echo ==========================================
echo.

exit /b 0
