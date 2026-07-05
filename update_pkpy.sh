#!/bin/sh

set -e
mkdir -p {libs,pocketpy}

# todo: make tmp
git clone https://github.com/pocketpy/pocketpy.git /tmp/pocketpy --depth=1

ROOT=$(pwd)

pushd /tmp/pocketpy

python amalgamate.py 

cp /tmp/pocketpy/amalgamated/pocketpy.h $ROOT/pocketpy/
cp /tmp/pocketpy/amalgamated/pocketpy.c $ROOT/pocketpy/

popd

rm -rf /tmp/pocketpy

gcc -c pocketpy/pocketpy.c -o pocketpy/pocketpy.o
ar rcs libs/libpocketpy.a pocketpy/pocketpy.o
