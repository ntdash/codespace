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
if [ "${ENABLE_NONROOT_DOCKER}" == "true" ];
then
   # Enabling docker usage to nonroot user
   chown -h "${USERNAME}":root "${TARGET_SOCKET}"

   # Install socat to help in case of a fallback from the first method
   pacman -Sy --noconfirm socat

   # replace placeholders by corresponding values...
   sed -e "s/\$ENABLE_NONROOT_DOCKER/${ENABLE_NONROOT_DOCKER}/g" -e "s/\$USERNAME/${USERNAME}/g" -e "s/\$TARGET_SOCKET/${TARGET_SOCKET}/g" -e "s/\$SOURCE_SOCKET/${SOURCE_SOCKET}/g" /tmp/docker-init.stub
else
   echo -e "#!/usr/bin/env bash\n\n" > /tmp/docker-init.stub
fi

# Store COMPOSE_FILE binder script in $DCO_ALIAS_SCRIPT
read -r -d '' DCO_ALIAS_SCRIPT << EOF

# Bind $HOST's compose-file to docker-compose command in a way to increase its usage scope from $DEV_CONFIG_PATHNAME

COMPOSE_FILE=$DEV_CONFIG_PATHNAME/docker-compose.yml

if [ -f \$COMPOSE_FILE ]
then
   echo -e "alias docker-compose=\\"docker-compose -f \$COMPOSE_FILE\\n\\n\\"" >> \$CUSTOM_ALIASES_PATH
fi

EOF

if [ "$DEV_CONFIG_PATH" != "undefined" ]
then
   DCO_ALIAS_SCRIPT=""
fi

sed -e "s/#::COMPOSE_FILE_BINDER_PLACEHOLDER::/${DCO_ALIAS_SCRIPT}/" /tmp/docker-init.stub

# Move stub into init.d
mv /tmp/docker-init.stub /usr/local/share/init.d/docker-init.sh

echo -e "\nDone!\n"
