#!/bin/bash

set -u
set -o errexit

if [[ "${TOUR_DEPLOY}" == "1" && "${TRAVIS_BRANCH}" == "master" && "${TRAVIS_PULL_REQUEST}" == "false" ]]; then
    docker login -u="$DOCKER_USERNAME" -p="$DOCKER_PASSWORD"
    docker tag dlangtour_test_image dlangtour/core
    docker push dlangtour/core
fi

bash <(curl -s https://codecov.io/bash)
