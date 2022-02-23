#! /usr/bin/env bash

USERNAME=${1:-'code'}
DEV_CONFIG_PATH=${2:-'undefined'}
ENABLE_NONROOT_DOCKER=${3:-'true'}


SOURCE_SOCKET="/var/run/docker-host.sock"
TARGET_SOCKET="/var/run/docker.sock"

# Install docker suite
pacman -Sy --noconfirm \
   helm \
   docker \
   kubectl \
   minikube \
   docker-compose


# By default, make the source and target sockets the same
touch "${SOURCE_SOCKET}"
ln -s "${SOURCE_SOCKET}" "${TARGET_SOCKET}"

# Allow nonroot user to use docker 
if [ "${ENABLE_NONROOT_DOCKER}" == "true" ]
then
   # Enabling docker usage to nonroot user
   chown -h "${USERNAME}":root "${TARGET_SOCKET}"

   # Install socat to help in case of a fallback from the first method
   pacman -Sy --noconfirm socat

   # replace placeholders by corresponding values...
   sed -i \
      -e "s^\$ENABLE_NONROOT_DOCKER^$ENABLE_NONROOT_DOCKER^g" \
      -e "s^\$USERNAME^$USERNAME^g" \
      -e "s^\$TARGET_SOCKET^$TARGET_SOCKET^g" \
      -e "s^\$SOURCE_SOCKET^$SOURCE_SOCKET^g" /tmp/scripts/docker-init.stub

else
   echo \
      -e "#!/usr/bin/env bash\n\n# PH_COMPOSE_FILE_BINDER" > /tmp/scripts/docker-init.stub
fi

# Try some other method to process the blocks below ... the one used is not optimal

# Store COMPOSE_FILE binder script temp file
tee /tmp/dco_alias_script.part > /dev/null << EOF

# Bind $HOST's compose-file to docker-compose command in a way to increase its usage scope from $DEV_CONFIG_PATH

COMPOSE_FILE=$DEV_CONFIG_PATH/docker-compose.yml

if [ -f \$COMPOSE_FILE ]
then
   echo -e "alias docker-compose=\"docker-compose -f \$COMPOSE_FILE\"" >> \$CUSTOM_ALIASES_PATH
fi

EOF

# Empty file if dev config file not defined ...
[ "$DEV_CONFIG_PATH" == "undefined" ] && echo "" > /tmp/dco_alias_script.part

sed -i \
   -e "/# PH_COMPOSE_FILE_BINDER/r /tmp/dco_alias_script.part" \
   -e '/# PH_COMPOSE_FILE_BINDER/d' /tmp/scripts/docker-init.stub

# remove tmp file
rm -f /tmp/dco_alias_script.part

# Move processed stub into init.d
mv /tmp/scripts/docker-init.stub /usr/local/share/init.d/docker-init.sh

echo -e "\nDone!\n"
