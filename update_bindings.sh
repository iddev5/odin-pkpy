#!/bin/sh

set -e

if [ ! -e odin-c-bindgen ]; then
    git clone https://github.com/karl-zylinski/odin-c-bindgen --depth=1
fi

odin run odin-c-bindgen/src -- .
