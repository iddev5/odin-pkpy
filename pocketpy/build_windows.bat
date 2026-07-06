@echo off

cd /d "%~dp0"

mkdir ..\libs

REM Debug
cl /std:c11 /experimental:c11atomics /utf-8 /c pocketpy.c
lib /OUT:..\libs\pocketpy_debug.lib /link Ws2_32.lib pocketpy.obj

REM Release
cl /std:c11 /experimental:c11atomics /utf-8 /c /Ox /DNDEBUG pocketpy.c
lib /OUT:..\libs\pocketpy_release.lib /link Ws2_32.lib pocketpy.obj

del *.obj