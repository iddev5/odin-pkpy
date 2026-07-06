#!/bin/sh

set -e

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

mkdir -p ../libs

# Debug
cc -std=c11 -g -c pocketpy.c
ar rcs ../libs/libpocketpy_debug.a pocketpy.o

# Release
cc -std=c11 -O2 -c -DNDEBUG pocketpy.c
ar rcs ../libs/libpocketpy_release.a pocketpy.o

rm *.o
