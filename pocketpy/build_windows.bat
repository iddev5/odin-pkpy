@echo off

cd /d "%~dp0"

mkdir ..\lib

REM Debug
cl /c pocketpy.c
lib /OUT:..\libs\pocketpy_release.lib pocketpy.obj

REM Release
cl /c /O2 /DNDEBUG pocketpy.c
lib /OUT:..\libs\pocketpy_release.lib pocketpy.obj

del *.obj