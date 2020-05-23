#!/bin/sh
set -e -u

cd /core/
dub build -c static --compiler=ldc2
