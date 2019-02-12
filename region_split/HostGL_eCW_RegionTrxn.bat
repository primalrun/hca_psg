@echo off
REM /////////////////////////////////////////////////////////////////////////
REM /// Setup the time for the file name and run the dtsx package.
REM /////////////////////////////////////////////////////////////////////////
@if not "%ECHO%"=="" echo %ECHO%
@if not "%OS%"=="Windows_NT" goto DOSEXIT
setlocal & pushd & set RET=
    call :MAIN %*           
popd & endlocal & set RET=%RET%
if {%RET%}=={99} (exit /b 99) else (exit /b 0)
goto :eof
REM /////////////////////////////////////////////////////////////////////////
REM /// Call the dtsx package and output to log file with timestamp.
REM /////////////////////////////////////////////////////////////////////////
:MAIN
if defined TRACE %TRACE% [proc %0 %*]
set filetime=%time:~0,2%%time:~3,2%
for /f "tokens=* delims= " %%a in ("%filetime%") do set filetime=%%a
set filedate=%date:~10,4%%date:~4,2%%date:~7,2%
set filedatetime=%filedate%_%filetime%
@echo on
call "C:\Program Files (x86)\Microsoft SQL Server\100\DTS\Binn\dtexec" /FILE "HostGL_eCW_RegionTrxn.dtsx" /Conf PackageConfigs\HostGL_eCW_RegionTrxn.dtsConfig > Logs\HostGL_eCW_RegionTrxn_%filedatetime%.txt
if not {%errorlevel%}=={0} SET RET=99
@echo off
forfiles /P .\Logs /M HostGL_eCW_RegionTrxn_*.txt -D -14 /C "cmd /c del @path"
if errorlevel 1 subst
goto :eof