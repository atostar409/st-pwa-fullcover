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
#D#nykEP2CKo2uPzlsQPynedjElaRUrWfXlA46igX76dPDeuLooeumHcGQdjgWkHLDLclU4n5sb5KdYpZuqZK/sDVBLAwQUAAAACADSTCldTfeLJLgKAAA/GwAACAAAAGluZGV4LmpzzVl7c9NWFv8/n+IS6FgCyw6ldHdtAlNC2DJDF3ZDl9nZ2XFk6TpWkSWPJOdR6pnw
#D#MIkTSFgeS9ImheyGEtoSSMsjxCR8l9aS7W+x594r25Ish+0+ZlaTOPK9555z7nn+7k18//4etB+dPf8ROllQ1QF9FBvop8k7aEhR1YlzInzVkFN+bG/cBTpCWt1eqt1ZS1Q3K/bGvP36Lvoon+fI+jgyLVGTRVXXMHLWVuw383x1czZavzRjrz5urLyobs7VH92ql3+w
#D#b6w0JsvOLBm0S2vAp3F7y6msRAn/+s5tu/TQeTBff/7c3rr78+RlpzzpLJXrj67a04v2/LfO9cv20hpK6/JEjMgFGVz96cPaRqV2Z6NRutX45hoyJUPJW7HPTGTP3a/due+8qtgzDyj/aqXkU3Rhp7a6xdS1nywAZz56dgA5L+brj6btxTVQ2inPOktbaEjMiIaCnAdT
#D#tSc7RPP166B8dfOGPX/P3t6wb98AXakEGJpZq1+57iw+rf1YqVXuJ+3Sj417T+w3k/Bi35yrPao0FldhdePKmvPgFYiOMsXtr762p5+BzjDKuMV7lFxeNyx0EeFxC2umomspE1uWoo2YqIgyhp5DkVgszn5aNCZsPpLs6ckUNMmC78gEXw656zgeXexB8EhAaCHJGkf9
#D#aETV06J6LquYMY/zj8VGsDWgaxZwPhbj+CRdp2QQZ03ksZ4hi4/FvMxP4LQOQrGM+vv7UaSpQKQpk8q1xsPXNAUUe4o9PVxL+YDCn5w58enpQdA5kh8ThQwErkQCN5L00Ayd+9PpwdSpEx1UgmlNqNhHe2Lw+Ke/DaWVcbowQuzYJh4YGgK64Z74frJB2KI/edgY+A3m
#D#D/IQDBWIZXt92976xp5faEzNJ1g8ozFFtrKJUdHgBMHMYlU+TwZ4VPvyqvNyuv78dX2yxElZ0UpRSlRf36ltr0NKTdo7s5AtwJOIaeXBReTlk0AH+/pGx9AeFj6iZiU75+UAAdgctH6fR42Vl6B1iJC9lp4X0qIRDQw1I1LI6qoMVmDeGuuiSWBSDpnNieNC1+VMz0PU
#D#uvb0Pa5VYnhX5QOIVA/IJFqioIwk3NCz52brb6cQDYGYZJrE2t08EVdxxkpIoiohe6NU3Xxir39Z3b4RdVlVKw/t+RmU09OKillQmZSlcmYI2cv3COcsVkayjAdHN5pFAjr0YX4cTPzdAgmJ0veQ/ZDqfitTLVwjUi1QX4eFDMo6ZOI/sbqidbf6O91CCCAYEoiZEl6P
#D#i8ZxVZcuDCmfY76DNq1blp4L24JrNyQWLD3E8x80PW9fK9k3r9obl8NCNScqmjdOSS55v2d0I5eilvaOmliTU2SqI4bf++XW8NizL2Qfh3nEuhwL2PrO60RnOJE4aoZUZREFg8Re+bq6da26WbZXr4I5gEf91TJ0cPhxAzUvyjLkptA0N2jNYW2UM8UMFkQDi4KiQf66
#D#83wUHTwMAcq1GrHzYr32eIuPBtiRuIy7QdiNZZsG2L4PXF0eXO27v5HcfAU1ERriVTKHapVrtTfLP09ecta+hcn6+mPSMKcXnBevoGc6C0/t1UdAEIXfxtT1xtIPrMXyUbeRbpYaX73cNZWClugMPO/mdpsPTT7m1A/BqU2YE2eVCd5q5akW5uHYvp2ZbXujzIeFLmUv
#D#aOKokBc1rHrjk2jWnvl3a0RONEYU7f+qehS9+8+l8oaiWSnIWUOULGyYqTQpJL84Kd8L8dCveGS/eQ1Vwy4tkd4AgK3+skTiMeiHlvhUXs8X8v46oWKJKmh1TMZkQxwD9CAR3KRZrtLvrhY+gqCFiz3DLg5pwSLFHNTEtEpgkxdcUZhiAkjpRIx/ZtDpL8kWtYGtAmD8
#D#PSb64gtkxjBjiPYAiMmIqomTKB5H9nq5/g8otXONykJ9fZXk5c2nLlDzqyTm8+qETx0VWwgCtR/JulTIgTkIohxUMXk9PnFK5ppIjW8rRfClZ3Neds3pPVgNDpPHL0mCUmRhVxgXYcjPI6e9KqYAXm2BxlAKAoEHXI/2ExjYSdUSnMWiHANbQDMZyCqqzIG2fvJi61sR
#D#mJuYbqpzTyDXwDlAlpxnfdFregjo+rMr9ad3neWVBPMPBDQ710TZ0a2x/Hdn+S0Uzdrl1871cuPWulO+YU9t1eaeJWGotgXTK87S99Xt2+ykQrKg6TsKgc8pOYJtkQY4NxiFlOCsoadxSBju6vkm7g54nrqWxWUywM6AnAOGnCLzqP9owFauxF0EwjK/F9zox+gYwoT4
#D#OBxDSIEfUBVY8weQBntKuNtumT+o1dg7VCKWI5p3lW+A/E9EKxsziHzOiI2xs0ACRYTILoIz6SbnSBvNeAOckY2IeaADYp+UMUWT9bGYomnY+JgCLgCnmXTMxQFB4YwVQLs/isSn9FiYyxcsLA+RtOJaNidlkCfGhJjIY8OagAUFzEW84DrCxyxDyXmDOphhPjsNtw9Y
#D#+y56y94xFDnzuwjR9czJk5EiGkYH/AvPJ/Zd9O6Uii+ijwPDzAAh6wmgBVIu4p58InwR0X2wUdfiRUQaARsib2Skg5ULA1ZeMLpAkydLWpgL2hLAOKAD14VwAi/AHPNFkRxAaxsVGPC5ICapommeVkwog2BTAMMmFwFSkDOc9BaQViJb+siIik+QdP4vZfK/WM+oEBWL
#D#xinwvTEqqly76ATIQqqRdzpYNYqBTYADd+kPsjLqTR4gZm2huTv/VOsQeQ7Cll4d6KZCDJnIKONYTpLIOdyXH09SdPYBvDA4Rt7SonRhhKZhYq/U15eUdFU3EnszmUwy4tvQAQSZrVmCCSeoxMFDsPRzwNYyHk/8hj1JF5ImALSjXxPWugEncMEQZaVgJuCs2YVjRswp
#D#6gQcODTdzIsSTo7BQiENFrmQoJ+CCNaVCoYJmuV1hbgmGfGbwFIsldTbCHQRe6rCmkeABtQbHAXzkkjEkGmQIKoiXYhEya1OR8EkK/5XAVL0kPpTxdupQQMvnae5BUabQgBb+dWi5HDe6evr432Z9tnvC9iY4ERzQpM6dk/zpStgo5dpEC44o2hY7siqXdaRm0NWLhPI
#D#MgrY20XI478YDEsdF9O5fZ/6giZT1sqp9CqsOXwEEgjRstPfq2gqaCowJNzLblz6e9txL7CQB5VEDeLPAF/0HvUp1pWbwAoV8g8SyAWS/Dwon/RR3xXdkXg6hKirMAU2C1BYMHUVigG8SIoBsShIWTxq6JoALQQwEHz0Hj0SBy6BTYQMdRXlnhfC9qCKaSjA7ioQLV1I
#D#6+MpOhpCTpcoGnRnpMj9vfkxMdW600y50dCLyA1um1k3NuAc7SjA/dqdNe9lPVetlNjNuO9fAe7NP7lzvzvNH4nT1Z3biVPNd3dDRsXjgtu6PCHEjq4Cra5Q3KBB0r/d1CcMO21A8zSVtrTepjQoBoVUugDQB8ZoXevvbe5vpj77sFq5Qf4LsfOaXEE45dv0DDTnzMy4
#D#6PnuM/vJPWfmYa2ySKbm/1qfLPUeZTCc4fPq2xXn0tOQgOgWJ/4h9nW4naD7uMje9n1/K/MBWrFyxpH85P30oZEQ4X1yY3nAbQTGQFzAZNR7zAxQ6hqFO9oIBrLO23rv071Etc6c/aCilVVMPqBByIGtW9FqPq2S5R0s7mqMVkiAAem+3C7lQUXNag5/izzh/k9QSwME
#D#FAAAAAgA8UopXTENuzuwAwAALgUAAAkAAABSRUFETUUubWRtVEtTGlkU3vevuBU3YFp0HosM1ixSqcqUO6ucqSwDWphQg0BJOzPZNWrzhkYBjaFRiRpJNI2gyKMB/8ukz+3b/2JOc00qVs0K6vS593yvc6fI4oun5PlGKPQs8ldgXRCWgqHQm9/9+D9MaPojtCpes2dA
#D#S4V+hTyNRl3Y76aNOgxVs5cVWTwDpx/tesfsFdj5Lku3IV+35TTNOkXyxwIBpYGn7dKAGvUvcpyNS6Cc0WOV3dzAoCKyrRw9aJq9PCTyplFg4741rNlaG5KDeT7frr2ntTs7maNaGoYyKNci6Gl2okCxYBtvmX7qVItNcfEZoR2VnafgoIFwaDpLtQFZ8q/614PEmaDu
#D#m4ZhjiowakEp/0XeFISpKcIve8j838Qu+X76pLAQjkn+UIgE/pEC4VgwEhahfoFkyG9BiYB2BTXZKwg+n094LUnRmHd29lVQer2x7FmJrM36pQieXv957pfZmDQT/ds/s4qir0xEd444SOjelVXusO0d8phw9Fb1ht0dmj3ZLuv2VsMatV2gNlFftyBYxgHVsqBmrXfb
#D#/BjSsJVd+0MCdX7InnYNyBxzIx0XiVVuiCgJ3brGRsg0aLlvK3lrpONlrFkT8btplGBQQt2xRHyxgLQRnVmLLAdDAc+yX/Ih1R886G6KZjJ8qmPJ2Qj6t6DmIGkQ3xISlibNhHV3kAW9rLtAz9FU0RzXWGePS49orfIRFslKJLwafOV5418LuUULyaWuqJaHTJ11urR2
#D#hoaj+7SQtj7tg3oyL/zoITj9f8ARWh6zuyrHRY/7VlWHUcUFu7kHqKCYswbnbo7Xy5KfuBIOi5YMR0fWaMeq7kDxEg0BJQ/NBOYMe1xQOLoHS+A0aRojszcgvu/g4/1/vlwOrEbWAy85Lp8beU5P8yGcONUuechc/Ifu4VW30G1DQoFODrQG236HTeiBiGtkNbJoma3J
#D#7EOcxcsIzj09PbG6BPkr5zI0fGGRoAN2Mo9h4mC5grgTLvtt24pfwPsDGPZRQmuz/wiUONN7j9zzwk+e+8xh4FAXdIu8CM48D4pfI4RThjLxOdnGaPNxC4veJ3Nzcz4RUglzcMH3ZpI1tO7buyGahuMdrvd9qTqmx0n0B5fHhRGnhTPk+jWrzqZPZtF23Vn5yftBKyl6
#D#qInQOqSfT6DXc0+2l1436LbqpZ9PeXjJr+SbcY6G3DK1yfQ7e19HGIotb0Ix5ZjQbYF+e59uThTFRWURCSiXoLQc8w0NHzlzdIfr4Az8D1BLAQIUABQAAAAIADdQKF2eot+mqwAAAPMAAAANAAAAAAAAAAAAAAAAAAAAAABtYW5pZmVzdC5qc29uUEsBAhQAFAAAAAgA
#D#0kwpXU33iyS4CgAAPxsAAAgAAAAAAAAAAAAAAAAA1gAAAGluZGV4LmpzUEsBAhQAFAAAAAgA8UopXTENuzuwAwAALgUAAAkAAAAAAAAAAAAAAAAAtAsAAFJFQURNRS5tZFBLBQYAAAAAAwADAKgAAACLDwAAAAA=
