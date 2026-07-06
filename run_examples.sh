#!/bin/sh

set -e

odin run example/00_hello
odin run example/01_casting_types
odin run example/02_bind_simple_fn
odin run example/03_call_python_fn
odin run example/04_bind_simple_struct
odin run example/05_bind_variadic_fn

odin run example/basic