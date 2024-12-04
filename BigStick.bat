@echo off
setlocal enabledelayedexpansion

:: Get the current date and time with seconds
for /f "tokens=2 delims==." %%B in ('wmic os get localdatetime /value') do set datetime=%%B

:: Extract components
set yy=!datetime:~2,2!
set mm=!datetime:~4,2!
set dd=!datetime:~6,2!
set hh=!datetime:~8,2!
set mn=!datetime:~10,2!
set ss=!datetime:~12,2!
set da=!date:~0,3!

:: Create log folder if it doesn't exist
if not exist "logs" (
    mkdir logs
)

:: Create log file name based on date and time (up to seconds to avoid too many files)
set logfilename=logs\!mm!!dd!!yy!_!hh!!mn!!ss!_puppy_log.txt

:: Append log entries with timestamp
for /f "delims=" %%a in ('PlayFetch.bat 2^>^&1') do (
    echo [!da! !mm!/!dd!/!yy! !hh!:!mn!:!ss!] %%a>> "!logfilename!"
)

echo Log file created: "!logfilename!"
pause
exit