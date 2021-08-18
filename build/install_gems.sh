#!/bin/sh

if [ "${RAILS_ENV}" = 'production' ]; then
  echo "Bundle install without development or test gems."
  bundle install --without development test -j $(nproc)
else
  echo "Bundle install with all gems."
  bundle install -j $(nproc)
fi
