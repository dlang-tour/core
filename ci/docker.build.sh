#!/bin/sh
set -e -u

cd /core/
dub build -c static --compiler=ldc2

# remove dub folder generated with build
# as it has root permissions from docker in the build folder
rm -rf ./.dub/
