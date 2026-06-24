@echo off
setlocal enabledelayedexpansion

REM Use JDK 17 via its short path to avoid spaces in command evaluation.
set "JAVA_HOME=C:\PROGRA~1\Microsoft\jdk-17.0.19.10-hotspot"
if not exist "%JAVA_HOME%\bin\java.exe" (
	echo ERROR: JDK 17 not found at %JAVA_HOME%
	exit /b 1
)
set "PATH=%JAVA_HOME%\bin;%PATH%"

cd /d C:\Users\HP\Desktop\KingdomHeirChurchAPP

echo Java version:
java -version

echo.
echo Starting Flutter APK build...
echo.

flutter build apk --debug

pause
