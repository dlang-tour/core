#!/bin/bash

set -u
set -o errexit

# Update all language repos to their latest content
git submodule update --init
git submodule foreach 'git fetch && git checkout origin/master'

# Compile & test with all compilers
# https://issues.dlang.org/show_bug.cgi?id=13742 + separate linking not implemented for LDC
if [[ "${DC}" == "dmd" ]]; then
    dub test --compiler=${DC} --build=unittest-cov --build-mode=singleFile
else
    dub test --compiler=${DC}
fi

dub --compiler=${DC} -- --sanitycheck

# Compile to static binary with ldc
if [[ "${DC}" == "ldc2" ]]; then
    dub build -c static --compiler=${DC}
    docker build -t dlangtour_test_image ./
    docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -ti dlangtour_test_image --wait-until-pulled --sanitycheck
fi
