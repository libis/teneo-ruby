#!/usr/bin/env bash

touch Gemfile

echo "updating gems ..."
bundle check > /dev/null 2>&1 || bundle install

echo "starting application: $@"
exec "$@"