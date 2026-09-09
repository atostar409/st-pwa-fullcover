@echo off
setlocal
cd /d "%~dp0"
title SillyTavern Mobile Access Setup

echo ==================================================
echo   SillyTavern mobile-access one-click setup
echo   (LAN listen + no password + st-pwa-fullcover)
echo ==================================================
echo.

if not exist "server.js" (
    echo [X] server.js not found next to this file.
    echo     Put setup-mobile.bat INTO the SillyTavern folder and run it again.
    goto :fail
)
if not exist "config.yaml" (
    echo [X] config.yaml not found.
    echo     Run Start.bat once first. Wait until the server is fully up,
    echo     close that window, then run setup-mobile.bat again.
    goto :fail
)

echo [1/3] Patching config.yaml ...
if not exist "config.yaml.bak_before_mobile" copy /y "config.yaml" "config.yaml.bak_before_mobile" >nul
powershell -NoProfile -ExecutionPolicy Bypass -Command "$f='config.yaml'; $c=[IO.File]::ReadAllText($f); $c = $c -replace '(?m)^listen:\s*\S+.*$','listen: true' -replace '(?m)^whitelistMode:\s*\S+.*$','whitelistMode: false' -replace '(?m)^basicAuthMode:\s*\S+.*$','basicAuthMode: false' -replace '(?m)^securityOverride:\s*\S+.*$','securityOverride: true'; [IO.File]::WriteAllText($f,$c)"
if errorlevel 1 goto :fail

echo [2/3] Installing st-pwa-fullcover extension ...
if exist "data\default-user\extensions\st-pwa-fullcover\manifest.json" (
    echo       already installed, skipping.
) else (
    mkdir "data\default-user\extensions" 2>nul
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=Join-Path $env:TEMP 'pwa-fullcover-setup'; Remove-Item -Recurse -Force $t -ErrorAction SilentlyContinue; New-Item -ItemType Directory -Path $t | Out-Null; [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12; Invoke-WebRequest 'https://github.com/atostar409/st-pwa-fullcover/archive/refs/heads/main.zip' -OutFile (Join-Path $t 'ext.zip'); Expand-Archive (Join-Path $t 'ext.zip') (Join-Path $t 'unz') -Force; Move-Item (Join-Path $t 'unz\st-pwa-fullcover-main') 'data\default-user\extensions\st-pwa-fullcover'; Remove-Item -Recurse -Force $t"
    if errorlevel 1 goto :fail
)

echo [3/3] All done. Your IPv4 address on this Wi-Fi:
ipconfig | findstr /i "ipv4"
echo.
echo  ON THE PHONE (same Wi-Fi):
echo    1. open Safari at  http://YOUR-PC-IP:8000
echo    2. Share -^> Add to Home Screen, always launch from that icon
echo    3. first load may stay grey for 15-60 seconds - that is normal
echo.
echo  Starting SillyTavern...
echo  ^>^> If Windows Firewall pops up, click ALLOW ^<^<
start "" cmd /c Start.bat
goto :end

:fail
echo.
echo Setup stopped. You can fix whatever it said above and run it again.
echo (If it failed at step 1, config.yaml was not modified.)

:end
pause
