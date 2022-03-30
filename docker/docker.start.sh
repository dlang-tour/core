#!/bin/sh

set -eu

< ./config.docker.yml \
  sed "s/%GOOGLE_ANALYTICS_ID%/${GOOGLE_ANALYTICS_ID:-}/g" | \
  sed "s/%GITHUB_TOKEN%/${GITHUB_TOKEN:-}/g" | \
  sed "s/%EXEC_DOCKER_MEMORY_LIMIT%/${EXEC_DOCKER_MEMORY_LIMIT:-512}/g" | \
  sed "s/%EXEC_DOCKER_MAX_QUEUE_SIZE%/${EXEC_DOCKER_MAX_QUEUE_SIZE:-10}/g" | \
  sed "s/%EXEC_DOCKER_TIME_LIMIT%/${EXEC_DOCKER_TIME_LIMIT:-25}/g" | \
  sed "s/%EXEC_DOCKER_MAX_OUTPUT_SIZE%/${EXEC_DOCKER_MAX_OUTPUT_SIZE:-4096}/g" | \
  sed "s@%TLS_CA_CHAIN_FILE%@${TLS_CA_CHAIN_FILE:-}@g" | \
  sed "s@%TLS_PRIVATE_KEY_FILE%@${TLS_PRIVATE_KEY_FILE:-}@g" \
  > ./config.yml

exec ./dlang-tour "$*"
