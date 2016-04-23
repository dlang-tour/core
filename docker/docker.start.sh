#!/bin/sh
set -e -u

cat /config.yml.tmpl | \
  sed "s/%GOOGLE_ANALYTICS_ID%/${GOOGLE_ANALYTICS_ID:-}/g" | \
  sed "s/%EXEC_DOCKER_MEMORY_LIMIT%/${EXEC_DOCKER_MEMORY_LIMIT:-256}/g" | \
  sed "s/%EXEC_DOCKER_MAX_QUEUE_SIZE%/${EXEC_DOCKER_MAX_QUEUE_SIZE:-10}/g" | \
  sed "s/%EXEC_DOCKER_TIME_LIMIT%/${EXEC_DOCKER_TIME_LIMIT:-20}/g" | \
  sed "s/%EXEC_DOCKER_MAX_OUTPUT_SIZE%/${EXEC_DOCKER_MAX_OUTPUT_SIZE:-4096}/g" \
  > /config.yml

exec /dlang-tour
