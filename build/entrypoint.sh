#!/bin/sh

# Pre-create needed directories
echo "Pre-creating directory trees"
for dir in /repo /data/tmp /data/public/ns /data/public/assets /data/public/system /data/public/uploads; do
   if [ ! -d "$dir" ]; then
      mkdir -p $dir
   fi
done

# Link SSH keys until we have ConfigMaps
echo "Linking SSH keys"
mkdir -p /root/.ssh
chmod 700 /root/.ssh
ln -sf /data/.ssh/id_rsa /root/.ssh/id_rsa
ln -sf /data/.ssh/id_rsa.pub /root/.ssh/id_rsa.pub
ln -sf /data/.ssh/id_rsa_github /root/.ssh/id_rsa_github
ln -sf /data/.ssh/id_rsa_github.pub /root/.ssh/id_rsa_github.pub
ln -sf /data/.ssh/config /root/.ssh/config

# Move this to another script
#echo "Cloning git repo"
#git clone git@github.com:OregonDigital/ControlledVocabularyManager.git /data/repo

# If a PID already exists, remove it
if [ -f /data/tmp/puma.pid ]; then
   rm -f /data/tmp/puma.pid
fi

# Install gems through bundle
echo "Building ${RAILS_ENV}"
./build/install_gems.sh

# Run database migrations if necessary
echo "Running database migrations"
./build/validate_migrated.sh


# Submit a marker to honeycomb marking the time the application starts booting
#if [ "${RAILS_ENV}" = 'production' ]; then
#  curl https://api.honeycomb.io/1/markers/sa-rails-${RAILS_ENV} -X POST -H "X-Honeycomb-Team: ${HONEYCOMB_WRITEKEY}" -d "{\"message\":\"${RAILS_ENV} - ${DEPLOYED_VERSION} - booting\", \"type\":\"deploy\"}"
#fi

# Start up puma
bundle exec puma -C config/puma/production.rb --dir /data --pidfile /data/tmp/puma.pid -b tcp://0.0.0.0:3000
