#!/bin/sh
set -e -u

cat /config.yml.tmpl | sed "s/%GOOGLE_ANALYTICS_ID%/${GOOGLE_ANALYTICS_ID:-}/g" > /config.yml

exec /dlang-tour
