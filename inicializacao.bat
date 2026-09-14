@echo off
setlocal EnableExtensions
title Cloud PC - Setup

echo ==========================================
echo        CONFIGURANDO CLOUD PC
echo ==========================================
echo.

echo [1/6] Ativando tema escuro...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul

echo [2/6] Configurando papel de parede...

set "WALLPAPER=%TEMP%\cloud_wallpaper.png"

powershell -NoProfile -ExecutionPolicy Bypass -Command "Invoke-WebRequest -Uri 'https://i.ibb.co/Y4mg7m8j/sla-185-F66-D.png' -OutFile '%WALLPAPER%'"

if exist "%WALLPAPER%" (
    reg add "HKCU\Control Panel\Desktop" /v Wallpaper /t REG_SZ /d "%WALLPAPER%" /f >nul
    reg add "HKCU\Control Panel\Desktop" /v WallpaperStyle /t REG_SZ /d 2 /f >nul
    reg add "HKCU\Control Panel\Desktop" /v TileWallpaper /t REG_SZ /d 0 /f >nul
    powershell -NoProfile -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\")] public static extern bool SystemParametersInfo(int uAction,int uParam,string lpvParam,int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20,0,'%WALLPAPER%',3)" >nul
)

echo [3/6] Organizando area de trabalho...

if not exist "%USERPROFILE%\Desktop\_Organizado" (
    mkdir "%USERPROFILE%\Desktop\_Organizado" >nul 2>&1
)

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v HideIcons /t REG_DWORD /d 1 /f >nul

echo [4/6] Criando atalho do Chrome...

set "CHROME="

for %%A in (
    "%ProgramFiles%\Google\Chrome\Application\chrome.exe"
    "%ProgramFiles(x86)%\Google\Chrome\Application\chrome.exe"
    "%LocalAppData%\Google\Chrome\Application\chrome.exe"
) do (
    if exist "%%~A" (
        set "CHROME=%%~A"
    )
)

if defined CHROME (
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$ws=New-Object -ComObject WScript.Shell; $s=$ws.CreateShortcut([Environment]::GetFolderPath('Desktop')+'\Google Chrome.lnk'); $s.TargetPath='%CHROME%'; $s.IconLocation='%CHROME%,0'; $s.Save()"
)

echo [5/6] Configurando Lixeira...

reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu" /v "{645FF040-5081-101B-9F08-00AA002F954E}" /t REG_DWORD /d 0 /f >nul

echo [6/6] Iniciando AnyDesk...
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
goto REFRESH

:FOUND

echo AnyDesk encontrado:
echo %ANYDESK%
echo.

start "" "%ANYDESK%"

timeout /t 8 /nobreak >nul

tasklist /FI "IMAGENAME eq AnyDesk.exe" | find /I "AnyDesk.exe" >nul

if errorlevel 1 (
    echo ERRO: AnyDesk nao esta executando.
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
    echo ERRO: Nao foi possivel obter o ID.
    goto REFRESH
)

if "%ID%"=="0" (
    echo ERRO: AnyDesk retornou ID 0.
    goto REFRESH
)

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
echo Tema: ESCURO
echo Papel de parede: CONFIGURADO
echo Area de trabalho: ORGANIZADA
echo Chrome: ATALHO CRIADO
echo Lixeira: ATIVADA
echo.
echo ==========================================

endlocal
exit /b 0
