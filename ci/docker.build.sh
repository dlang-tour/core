#!/bin/sh
set -e -u

cd /core/
DFLAGS="-linker=bfd" dub build -c static --compiler=ldc2
