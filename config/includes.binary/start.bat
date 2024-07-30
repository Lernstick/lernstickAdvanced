@echo off

:init
 setlocal DisableDelayedExpansion
 set cmdInvoke=1
 set winSysFolder=System32
 set "batchPath=%~dpnx0"
 for %%k in (%0) do set batchName=%%~nk
 set "vbsGetPrivileges=%temp%\OEgetPriv_%batchName%.vbs"
 setlocal EnableDelayedExpansion

:checkPrivileges
  NET FILE 1>NUL 2>NUL
  if '%errorlevel%' == '0' ( goto gotPrivileges ) else ( goto getPrivileges )

:getPrivileges
  if '%1'=='ELEV' (echo ELEV & shift /1 & goto gotPrivileges)
  ECHO Set UAC = CreateObject^("Shell.Application"^) > "%vbsGetPrivileges%"
  ECHO args = "ELEV " >> "%vbsGetPrivileges%"
  ECHO For Each strArg in WScript.Arguments >> "%vbsGetPrivileges%"
  ECHO args = args ^& strArg ^& " "  >> "%vbsGetPrivileges%"
  ECHO Next >> "%vbsGetPrivileges%"
  
  if '%cmdInvoke%'=='1' goto InvokeCmd 

  ECHO UAC.ShellExecute "!batchPath!", args, "", "runas", 1 >> "%vbsGetPrivileges%"
  goto ExecElevation

:InvokeCmd
  ECHO args = "/c """ + "!batchPath!" + """ " + args >> "%vbsGetPrivileges%"
  ECHO UAC.ShellExecute "%SystemRoot%\%winSysFolder%\cmd.exe", args, "", "runas", 1 >> "%vbsGetPrivileges%"

:ExecElevation
 "%SystemRoot%\%winSysFolder%\WScript.exe" "%vbsGetPrivileges%" %*
 exit /B

:gotPrivileges
 setlocal & cd /d %~dp0
 if '%1'=='ELEV' (del "%vbsGetPrivileges%" 1>nul 2>nul  &  shift /1)

@echo off
:: Get Manufaturer
for /f "tokens=2 delims='='" %%a in ('wmic ComputerSystem Get Manufacturer /value') do (
  SET manufacturer=%%a
)

if /i "%manufacturer%"=="LENOVO" GOTO start_lenovo
if /i "%manufacturer%"=="Microsoft Corporation" GOTO start_microsoft
if /i "%manufacturer%"=="HP" GOTO start_hp
if /i "%manufacturer%"=="Acer" GOTO start_acer
if /i "%manufacturer%"=="Dell Inc." GOTO start_dell

:start_lenovo
bcdedit /enum FIRMWARE > "%temp%\bootFirmware.txt"
for /f "tokens=*" %%a in ('type "%temp%\bootFirmware.txt"') do (
  echo %%a | findstr /r " USB.HDD" > NUL
  if errorlevel 1 (
   rem "No match"
  ) else (
     for /f "tokens=2" %%b in ("!lastLine!") do (
  	set startId=%%b
        goto startup
     )
  )
  set lastLine=%%a
)
goto no_device


:start_microsoft
bcdedit /enum FIRMWARE > "%temp%\bootFirmware.txt"
for /f "tokens=*" %%a in ('type "%temp%\bootFirmware.txt"') do (
  echo %%a | findstr /r " USB.Storage" > NUL
  if errorlevel 1 (
   rem "No match"
  ) else (
     for /f "tokens=2" %%b in ("!lastLine!") do (
  	set startId=%%b
        goto startup
     )
  )
  set lastLine=%%a
)
goto no_device

:start_hp
bcdedit /enum FIRMWARE > "%temp%\bootFirmware.txt"
for /f "tokens=*" %%a in ('type "%temp%\bootFirmware.txt"') do (
  echo %%a | findstr /r " USB:" > NUL
  if errorlevel 1 (
   rem "No match"
  ) else (
     for /f "tokens=2" %%b in ("!lastLine!") do (
  	set startId=%%b
        goto startup
     )
  )
  set lastLine=%%a
)
goto no_device

:start_acer
bcdedit /enum FIRMWARE > "%temp%\bootFirmware.txt"
for /f "tokens=*" %%a in ('type "%temp%\bootFirmware.txt"') do (
  echo %%a | findstr /i /r " Linpus.lite" > NUL
  if errorlevel 1 (
   rem "No match"
  ) else (
     for /f "tokens=2" %%b in ("!lastLine!") do (
  	set startId=%%b
        goto startup
     )
  )
  set lastLine=%%a
)
goto no_device

:start_dell
bcdedit /enum FIRMWARE > "%temp%\bootFirmware.txt"
for /f "tokens=*" %%a in ('type "%temp%\bootFirmware.txt"') do (
  echo %%a | findstr /i /r " USB.Storage.Device" > NUL
  if errorlevel 1 (
   rem "No match"
  ) else (
     for /f "tokens=2" %%b in ("!lastLine!") do (
  	set startId=%%b
        goto startup
     )
  )
  set lastLine=%%a
)
goto no_device

:startup
echo !startId! | findstr /r "{[a-f0-9\-]*}" > NUL
if errorlevel 1 (
   GOTO no_device
) else (
   echo "Start device found"
   bcdedit /set {fwbootmgr} bootsequence !startId!
   shutdown -r -t 0
)
goto:eof

:no_device
echo "No start device found"
echo "Press Enter for manual USB drive selection"
pause
shutdown /r /o /f /t 00

