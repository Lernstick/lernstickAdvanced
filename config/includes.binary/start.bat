@echo off
for /f "delims=" %%a in ('powershell -NoProfile -Command "Switch ((Get-CimInstance -ClassName Win32_Processor).Architecture){ 0 {'x86'}; 1 {'MIPS'}; 2 {'Alpha'}; 3 {'PowerPC'}; 5 {'ARM'}; 6 {'Itanium'}; 9 {'x64'} }"') do (
  SET arch=%%a
)
if /i "%arch%"=="ARM" echo "[91mARM-Architecture detected: [93mLernstick does not support Snapdragon or CoPilot+ Processors yet![0m" & pause & exit /b

for /f "tokens=* USEBACKQ" %%a in (`powershell -NoProfile -Command "(Get-CimInstance -ClassName Win32_ComputerSystem).Manufacturer"`) do (
  SET manufacturer=%%a
)

if /i "%manufacturer%"=="LENOVO" GOTO init
if /i "%manufacturer%"=="Microsoft Corporation" GOTO init
if /i "%manufacturer%"=="HP" GOTO init
if /i "%manufacturer%"=="Acer" GOTO init
if /i "%manufacturer%"=="Dell Inc." GOTO init
goto no_device

:no_device
echo "[93mAutomatic detection of external start device was not possible:[0m"
echo "[92mPlease press any key for restart and manual selection of USB drive/Lernstick...[0m"
pause
shutdown /r /o /f /t 00

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
   echo "[92mStart device found[0m"
   bcdedit /set {fwbootmgr} bootsequence !startId!
   shutdown -r -t 0
)
goto:eof