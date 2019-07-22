#!/bin/sh

echo "Building ${RAILS_ENV}"

./build/install_gems.sh

# Do not auto-migrate for production environment
if [ "${RAILS_ENV}" != 'production' ]; then
  ./build/validate_migrated.sh
fi

# Submit a marker to honeycomb marking the time the application starts booting
if [ "${RAILS_ENV}" = 'production' ]; then
  curl https://api.honeycomb.io/1/markers/sa-rails-${RAILS_ENV} -X POST -H "X-Honeycomb-Team: ${HONEYCOMB_WRITEKEY}" -d "{\"message\":\"${RAILS_ENV} - ${DEPLOYED_VERSION} - booting\", \"type\":\"deploy\"}"
fi