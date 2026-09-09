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

echo [2/3] Installing st-pwa-fullcover extension (bundled, no download) ...
if exist "data\default-user\extensions\st-pwa-fullcover\manifest.json" (
    echo       already installed, skipping.
) else (
    mkdir "data\default-user\extensions" 2>nul
    set "SELF=%~f0"
    powershell -NoProfile -ExecutionPolicy Bypass -Command "$d = Get-Content -LiteralPath $env:SELF | Where-Object { $_ -like '#D#*' } | ForEach-Object { $_.Substring(3) }; if (-not $d) { exit 1 }; $z = Join-Path $env:TEMP 'pwa-fullcover-ext.zip'; [IO.File]::WriteAllBytes($z, [Convert]::FromBase64String(($d -join ''))); Expand-Archive -LiteralPath $z -DestinationPath 'data\default-user\extensions\st-pwa-fullcover' -Force"
    if errorlevel 1 (
        echo       [!] Failed to unpack the bundled extension.
        echo           The config patch from step 1 is saved, the server still works.
        echo           Install the extension manually: copy the st-pwa-fullcover
        echo           folder into  data\default-user\extensions\
    )
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
exit /b

REM ===== PAYLOAD: base64 of zip(manifest.json + index.js + README.md), lines prefixed with #D# =====
#D#UEsDBBQAAAAIADdQKF2eot+mqwAAAPMAAAANAAAAbWFuaWZlc3QuanNvbk2PSwvCMBCE7/0VIWebtuDF3kTw3JsHkbI2sY2k2ZiHD8T/blKruKflm2F255mROJRLZxQ8Wg2joDWhzW5NtkGpDV6FpYuPSSFwqfsWLY+wJtXMrbgEaYWLaH+YGRovUYP6Z+fkoFJzcWdx
#D#nykEP2CKo2uPzlsQPynedjElaRUrWfXlA46igX76dPDeuLooeumHcGQdjgWkHLDLclU4n5sb5KdYpZuqZK/sDVBLAwQUAAAACAA1UChd7Nm38mMKAAADGgAACAAAAGluZGV4LmpzzVj7c9NGHv89f8US2pEEfoRSenc2gYEQrszQg7vQY25ubhxZWscqsqSR5DxKPRMe
#D#JnFCEg7IkbRJIXehhLYkpOWRxCT8L60l2//FfXdXdiTZCdd7zJyHh7373e/78dmNHzrUgQ6hi5dPobN5Ve3RB7GJfhq9j/oUVR25JMJPDbmlp876LNAR0sr2QvX+SqKyUXbWZ5zNWXTKMHhyPo4sW9RkUdU1jNyVJefNjFDZmIzUrk04y0/rSy8rG9O1J3drpR+cqaX6
#D#aMmdJItOcQX41O9tueWlCOFf27nnFB+7j2ZqL144W7M/j153S6PuQqn25KYzPu/MfOvevu4srKC0Lo/EiFyQwdfWHlfXy9X76/Xi3fo3t5AlmYphxz6zkDP9sHr/ofu67Ew8ovwr5WJA0bmd6vIWU9d5NgechcjFHuS+nKk9GXfmV0BptzTpLmyhPjEjmgpyH41Vn+0Q
#D#zVdvg/KVjSln5oGzve7cmwJdqQRYmlip3bjtzq9VfyxXyw+TTvHH+oNnzptR+OLcma4+Kdfnl+F0/caK++g1iI4wxZ2vvnbGn4POsMq4xTuUnKGbNrqK8LCNNUvRtZSFbVvRBixUQBlTzyEuFouzP00aC4znkh0dmbwm2fAbWRDLPu8cL6CrHQg+EhDaSLKHUTcaUPW0
#D#qF7KKlbMF/yTsQFs9+iaDZxPxnghSc8pGcTbIwbWM+TwyZif+Rmc1kEollF3dzfiGgpwDZlUrj3c/kxDQKGj0NHBN5UPKfzJhTOfnu8FnTljSIxmIHElkrhc0kfTd+lP53tT5860UEUte0TFAdozvac//W1bWhmn8wPEj7vEPX19QNffET9EDAQTg8XD1iBusH9EgGQo
#D#Qy47q9vO1jfOzFx9bCbB8hkNKbKdTQyKJh+NWlmsypfJgoCqX950X43XXmzWRou8lBXtFKVEtdWd6vYqlNSoszMJ1QI8iZhmHVxFfj4JdKSra3AIHWDpI2p2snVfDhGAz0HrDwRUX3oFWrcRctDWjWhaNCOhpUZGRrO6KoMXWLSG9tAktCm32c2Jw9E9jzM9j1LvOuMP
#D#+GaLETyVDyPSPaCSaIuCNpLwUs+Znqy9HUM0BWKSZRFv7xWJuIozdkISVQk568XKxjNn9cvK9lTEY1UpP3ZmJlBOTysqZkllUZbKhT7kLD4gnLNYGcgyHjw1NIui6OhHxjC4+Ls5khLF76H6odSDXqZaeE6kWqCuFg+ZlHWbjf/E64q2t9ffGRZCAMmQQMyV8PW0aJ5W
#D#delKn/I5Flpo07pt67l2Jnh+Q2Le1ttE/sNG5J1bRefOTWf9ertUzYmK5s9TUkv+3xndzKWop/2rFtbkFNlqyeH3f7k3fP7samPHMQGxKccStrazmWhNJ5JHjZQqz6NwkjhLX1e2blU2Ss7yTXAH8Ki9XoQJDn+8RDVEWYbajDbcDVrzWBvkLTGDo6KJxaiiQf16+0IE
#D#HTkGCco3B7H7crX6dEuIhNiRvIx7SbgXy10aYPsBcPV48NXv/kZq8zX0RBiIN8keqpZvVd8s/jx6zV35FjZrq0/JwByfc1++hpnpzq05y0+AIAJ/62O36ws/sBErRLxBulGsf/Vq31IKe6I18fzG7bfftvhYUD+CoDZgTpx1JvhWLY01MQ/P7HYntp31ktAudSn7qCYO
#D#Rg1Rw6o/P4lmuzv/bo/IieaAov1fdY+C3/5cyjAVzU5BzZqiZGPTSqVJI/nFRfl+mwj9SkDOm03oGk5xgcwGAGy1V0WSj+E4NMWnDN3IG8E+oWKJKmi3bMZkUxwC9CAR3KTZntLv7hYBgrCHCx39Hg5pwiLF6tXEtEpgkx9cUZhiAUhpRYx/ZtDpL8kmtYntPGD8Axb6
#D#4gtkxTBjiA4AiMmIqoWTKB5Hzmqp9g9otdP18lxtdZnU5Z01D6gFVRINQx0JqKNiG0GidiNZl/I5cAdBlL0qJl9Pj5yT+QZSE3aVIvjSZ5yfXWP7AFbDy+QTlCRBK7KxJ4znGPLzydk9FVMArzZBY1sKAoF7vIh2ExjYStUUnMWiHANfwDDpySqqzIO2QfJC81cBmFuY
#D#GtVqE8g1cQ6QJe87X/C7HhK69vxGbW3WXVxKsPhAQrN7TYRd3eqLf3cX30LTrF7fdG+X6ndX3dKUM7ZVnX6ehKXqFmwvuQvfV7bvsZsKqYJG7CgEvqTkCLZFGuDccBZSgoumnsZt0nDfyDdwdyjyNLQsL5MhdibUHDDkFVlA3SdCvvIk7iMQjgWj4GU/RicRJsSn4RpC
#D#GnyPqsCZP4A0sCnhmd10f1iroXeoRDxHNN9TvgnyPxHtbMwk8nkzNsTuAgnERbl9BGfSDc7cLprxJzgjGxANoAPigJQhRZP1oZiiadj8mAIuAKeZdMzDAWHhjBVAuz+KJKb0Wpgz8jaW+0hZ8U2fkzYoEGdCThjYtEfgQB7znB9cc0LMNpWcP6nDFRbwU//uBeu9q/62
#D#dxJxF37HEV0vnD3LFVA/Ohw8eDnx3lW/pVR8AX0cWmYOaHOeAFog5Tnv5sMJBUTtYKuexwuIDAK2RL6RlRZWHgxYesnoQkOeHGliLhhLAOOADkLXhhNEAfZYLArkAlpdL8NCIAQxSRUt67xiQRsEnwIYtngOSEFOf9LfQJqFbOsDAyo+Q8r5v1TJ/2I/o0JULJrnIPbm
#D#oKjyu00nRNamG/m3w12jEDICArjPfJCVQX/xADEbCw3rglvNS+QlSFv6dKBbCnFkIqMMYzlJMudYlzGcpOjsQ/jC4Bj5lhalKwO0DBMHpa6upKSrupk4mMlkklzAoMMIKluzoxbcoBJHjsLRzwFby3g48Rv2SXqQNAGgHf2asNZNuIFHTVFW8lYC7pp7cMyIOUUdgQuH
#D#pluGKOHkEByMpsEjVxL036gI3pXypgWaGbpCQpPkgi6wFVsl/ZaDKeKMldnwCNGAer2D4F6SiRgqDQpEVaQrXIS86rQ0THLif5UgBR9psFT8kxo08NP5hltotSEEsFVQLUoO952uri4hUGmf/T6PzRFetEY0qcV6Wi97Ajb6mAbpgjOKhuWWqtrnHHk5ZO0ygWwzj/1T
#D#hHyCD4PtSsfDdN7cp7GgxZS1cyp9CmssH4cCQrTtdHeG3tw8AZ0nArKPq2Ia+op3RMpi6UpaH07R1RApJVc0GDhIkSn7VJN9yjOwE5FHyV1G7VhArmsnAk92u2/ZpwzDewn2vUrzlXKRPQGTPnv/oTs7HrnY43/3FY7HKdegaXFqRWjR56CMioejXmfGZid7k+ruZDez
#D#KG0eULvQ/+n/7UwhzFp9QVMwlba1zoYkyPN8Kp2HqQ5rtGS7O5lFlY2J2uTjSnmKPLDvbJLbtVu6R+H9tDsx4QHD2efOswfuxONqeZ5szfy1NlrsPMEQJoOelbdL7rW143HQKOyFwBL72b+bZO/x3MHdN+tm9gI8YCXJkxwTgvRtQ88JAbkxA7AHGcWQCLAZ8V+VQpS6
#D#Rke2NoCBrPXF2f/Zu8ya96ZuUNHOKpYQ0qDNpWOvwmt8mmXnXyzs64xm7MGB1C6v0/ome6Mjwf8FgXD/J1BLAwQUAAAACAAYSCldHgI0e4UDAADxBAAACQAAAFJFQURNRS5tZG1UXU8aWRi+n19xUm8gO6Ld3YtdTC+aJm28M3E3veygwZYUgci4296BOnzDoECtZVCp
#D#Wmm1g6BUYPj4L9t5z5z5F32HQ5ua7B15Oec8n+/MkKWnD8njzWDwUfgf/4YgLAeCwdd/+fB3iND0R2hVvGbXgJYKvQp5GIm48LybNuowUM1uVmTxDJx+tOsds1tg53ss3YZ83Y6ladYZkr8XCSgNvG2X+tSof43F2agEyhk9VtnNDfQrItvO0YOm2c1DIm8aBTbqWYOa
#D#rbUh2V/g+HbtPa2N7WSOamkYxEC5FkFPsxMFigXbeMv0U2dabIpLjwjtqOw8BQcNpEPTWar1ybJvzbcRIA6Cum8ahjmswLAFpfzX2JYgzMwQ/thd5f8l9sjP6JPBYigq+4JB4n8l+0PRQDgkQv0CxZAnAZmAdgW1mFcQJEkSXshyJOqdm3sekF9srnhWw+tzPjmMtzd+
#D#n/9zLirPRv71za6h6asT050rDhP65soqd9jOLvmFcPZW9YaND81uzC7r9nbDGrZdoDbRX7cgWMYB1bKgZq13O/wayrCVPftDAn2+q57eGpA55kE6KRKr3BDRErp9jQch06Dlnq3kraGOj7FmTcT/TaME/RL6jiMiRf3yZmR2PbwSCPo9Kz5ZQqn3PZhuimYyHNWJ5GwI
#D#vS+g5iBpEGkZBcuTw4Td7qIKell3gZ6jqaI5qrHOG249srXKRzgkq+HQWuC557VvPegWLRSXuqJaHjJ11rmltTMMHNOnhbT1aR/UkwXhVw9B9P8hR2h5xMZVzose96yqDsOKC/Zyd1hBMWf1z92cr5clP3EnHBWtGBwdWcNdq7oLxUsMBJQ8NBPYMzzjgsLRlCyB06Rp
#D#DM1un0g/0cf3Xz5b8a+FN/zPOC/J7bR/AsFlU+2SV2ySVgnyV84EM1tcImiincxjHzgeNwFr7bLftq34Bbw/gEEPXbC2evdAiTO9e8+9IPzmmdYGO4PS0HDyNDD7OCB+bwGiDGJEcuqJ7eRwi0veP+bn5yURUgmzf8GrP6kLuv9j9UXTcOzHDZ2OqiN6nESLsf8ubCkt
#D#nIHW+F43Z1knWLRdd7Z28gmglRQ91ERoHdLPJ9DtuicLSK8bdEf10s+nvH/kAfnhPSSUqetqk+lje19HGood24JiynHytgX6l2lBuVCsNPsQRyagXILScvIzNPxOmcMxNtoB/AZQSwECFAAUAAAACAA3UChdnqLfpqsAAADzAAAADQAAAAAAAAAAAAAAAAAAAAAAbWFu
#D#aWZlc3QuanNvblBLAQIUABQAAAAIADVQKF3s2bfyYwoAAAMaAAAIAAAAAAAAAAAAAAAAANYAAABpbmRleC5qc1BLAQIUABQAAAAIABhIKV0eAjR7hQMAAPEEAAAJAAAAAAAAAAAAAAAAAF8LAABSRUFETUUubWRQSwUGAAAAAAMAAwCoAAAACw8AAAAA
