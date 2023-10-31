@echo off
setlocal enabledelayedexpansion

set adapter=Ethernet

set /p type=Choose configuration type [DHCP (1), static (2)]:
if %type% == 1 (
    call :setDHCPConfig
) else if %type% == 2 (
    call :setStaticConfig
) else (
    echo Incorrect option
)

goto:eof

:reloadConfig
echo Updating config...
timeout /t 5 /nobreak > nul
netsh interface ip show config !adapter!
goto :eof

:setDHCPConfig
netsh interface ip set address !adapter! dhcp
netsh interface ip set dnsservers !adapter! dhcp
call :reloadConfig
goto :eof

:setStaticConfig
set configArgs=

set /p ipAddress=Enter IP address:

if not [!ipAddress!] == [] (
    set configArgs=!configArgs! address^=!ipAddress!

    set /p ipMask=Enter IP mask:
    if not [!ipMask!] == [] (
        set configArgs=!configArgs! mask^=!ipMask!
    )

    set /p gateway=Enter gateway:
    if not [!gateway!] == [] (
        set configArgs=!configArgs! gateway^=!gateway!
    )
)

netsh interface ip set address !adapter! static !configArgs!

set /p dns=Enter DNS:
if not [%dns%] == [] (
    netsh interface ip set dnsservers !adapter! static %dns% primary no
)

call :reloadConfig
goto :eof
