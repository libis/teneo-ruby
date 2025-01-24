#!/usr/bin/env bash

touch Gemfile

case "$BUNDLE_COMMAND" in
    "")
        ;;
    install)
        echo "installing gems ..."
        bundle check > /dev/null 2>&1 || bundle install
        ;;
    update)
        echo "updating gems ..."
        bundle check > /dev/null 2>&1 || bundle update
        ;;
    *)
        echo "unknown command: $BUNDLE_COMMAND"
        exit 1
        ;;
esac

echo "starting application: $@"
bundle exec "$@"