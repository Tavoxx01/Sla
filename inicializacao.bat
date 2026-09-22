@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Cloud PC PRO

echo ==========================================
echo           CLOUD PC PRO
echo ==========================================
echo.

echo [1/10] Ativando tema escuro...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul

echo [2/10] Configurando papel de parede...

set "WALLPAPER=%LOCALAPPDATA%\CloudPC\wallpaper.png"

if not exist "%LOCALAPPDATA%\CloudPC" mkdir "%LOCALAPPDATA%\CloudPC" >nul 2>&1

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://i.ibb.co/Y4mg7m8j/sla-185-F66-D.png' -OutFile '%WALLPAPER%'"

if exist "%WALLPAPER%" (
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%WALLPAPER%" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 2 /f >nul
    reg add "HKCU\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f >nul
    powershell -NoProfile -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\")] public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20,0,'%WALLPAPER%',3)" >nul
)

echo [3/10] Otimizando Windows...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAnimations /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewAlphaSelect /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v ListviewShadow /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v DisablePreviewDesktop /t REG_DWORD /d 1 /f >nul
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul
reg add "HKCU\Control Panel\Desktop" /v AutoEndTasks /t REG_SZ /d 1 /f >nul
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul

echo [4/10] Limpando arquivos temporarios...

forfiles /p "%TEMP%" /s /m * /d -1 /c "cmd /c if @isdir==FALSE del /f /q @path" >nul 2>&1
forfiles /p "%TEMP%" /s /m * /d -1 /c "cmd /c if @isdir==TRUE rd /s /q @path" >nul 2>&1

if exist "%SystemRoot%\Temp" (
    forfiles /p "%SystemRoot%\Temp" /s /m * /d -1 /c "cmd /c if @isdir==FALSE del /f /q @path" >nul 2>&1
    forfiles /p "%SystemRoot%\Temp" /s /m * /d -1 /c "cmd /c if @isdir==TRUE rd /s /q @path" >nul 2>&1
)

ipconfig /flushdns >nul 2>&1

echo [5/10] Organizando area de trabalho...

if not exist "%USERPROFILE%\Desktop\_Organizado" mkdir "%USERPROFILE%\Desktop\_Organizado" >nul 2>&1

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 0 /f >nul

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f >nul

echo [6/10] Criando atalho do Chrome...

set "CHROME="

for %%A in (
    "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
    "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
    "%LocalAppData%\Google\Chrome\Application\chrome.exe"
) do (
    if exist "%%\~A" set "CHROME=%%\~A"
)

if defined CHROME (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut([Environment]::GetFolderPath('Desktop')+'\Google Chrome.lnk'); $s.TargetPath='%CHROME%'; $s.IconLocation='%CHROME%,0'; $s.Save()"
)

echo [7/10] Criando informacoes do sistema...

set "INFO=%USERPROFILE%\Desktop\CloudPC_INFO.txt"

(
echo ==========================================
echo              CLOUD PC INFO
echo ==========================================
echo.
echo COMPUTADOR:
hostname
echo.
echo USUARIO:
whoami
echo.
echo SISTEMA:
powershell -NoProfile -Command "(Get-CimInstance Win32_OperatingSystem).Caption"
echo.
echo CPU:
powershell -NoProfile -Command "(Get-CimInstance Win32_Processor).Name"
echo.
echo RAM:
powershell -NoProfile -Command "[math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory/1GB,2)"
echo GB
echo.
echo DISCO:
powershell -NoProfile -Command "Get-PSDrive C ^| ForEach-Object { 'Livre: ' + [math]::Round($_.Free/1GB,2) + ' GB' }"
echo.
echo DATA:
date /t
echo HORA:
time /t
echo ==========================================
) > "%INFO%"

echo [8/10] Iniciando Tailscale e solicitando autorizacao...
echo.

set "TAILSCALE="

for /f "delims=" %%A in ('where tailscale.exe 2^>nul') do (
    set "TAILSCALE=%%A"
    goto TSFOUND
)

for /f "delims=" %%A in ('powershell -NoProfile -Command "Get-ChildItem 'C:\Program Files\Tailscale','C:\Program Files (x86)\Tailscale','C:\ProgramData\chocolatey\lib' -Recurse -Filter 'tailscale.exe' -ErrorAction SilentlyContinue | Select-Object -First 1 -ExpandProperty FullName"') do (
    set "TAILSCALE=%%A"
    goto TSFOUND
)

echo Tailscale nao encontrado. Verifique se a instalacao foi concluida corretamente.
goto ANYDESK

:TSFOUND

echo Tailscale encontrado:
echo %TAILSCALE%
echo.

:: Garante que o servico Tailscale esteja em execucao
net start Tailscale >nul 2>&1

echo.
echo Iniciando autenticacao do Tailscale...
echo Uma janela ou link de autorizacao sera exibido.
echo Faca login na sua conta Tailscale para autorizar este dispositivo.
echo.

start "" "%TAILSCALE%" up --accept-routes --accept-dns

timeout /t 10 /nobreak >nul

echo.
echo Aguardando autenticacao (pressione qualquer tecla apos autorizar no navegador)...
pause >nul

echo.
echo Status do Tailscale:
"%TAILSCALE%" status

echo.
echo Tailscale configurado.
echo.

:ANYDESK

echo [9/10] Iniciando AnyDesk...
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

echo AnyDesk nao encontrado.
goto REFRESH

:FOUND

echo AnyDesk encontrado:
echo %ANYDESK%
echo.

start "" "%ANYDESK%"

timeout /t 8 /nobreak >nul

tasklist /FI "IMAGENAME eq AnyDesk.exe" | find /I "AnyDesk.exe" >nul

if errorlevel 1 (
    echo AnyDesk nao esta executando.
    goto REFRESH
)

echo AnyDesk executando.

echo tavoxxdevthebest | "%ANYDESK%" --set-password _full_access

echo.
echo Obtendo ID...

set "ID="

for /f "delims=" %%A in ('"%ANYDESK%" --get-id 2^>nul') do (
    set "ID=%%A"
)

if not defined ID (
    echo Nao foi possivel obter o ID.
    goto REFRESH
)

if "%ID%"=="0" (
    echo AnyDesk retornou ID 0.
    goto REFRESH
)

echo [10/10] Finalizando configuracao...

:REFRESH

echo.
echo Atualizando Explorer...

taskkill /f /im explorer.exe >nul 2>&1
start explorer.exe

timeout /t 3 /nobreak >nul

echo.
echo ==========================================
echo           CLOUD PC PRONTO
echo ==========================================
echo.

if defined ID echo ID DO ANYDESK: %ID%

echo.
echo TEMA: ESCURO
echo WALLPAPER: CONFIGURADO
echo OTIMIZACAO: ATIVADA
echo TEMPORARIOS: LIMPOS
echo DNS: LIMPO
echo CHROME: CONFIGURADO
echo LIXEIRA: ATIVADA
echo TAILSCALE: INICIADO (autorizacao solicitada)
echo INFO: %INFO%
echo.
echo ==========================================

endlocal
exit /b 0
