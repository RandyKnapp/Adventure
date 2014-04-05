@echo off
echo Compiling game...
"C:\Program Files (x86)\Lua\5.1\luac.exe" -p "main.lua"
if "%ERRORLEVEL%" == "0" echo Success
