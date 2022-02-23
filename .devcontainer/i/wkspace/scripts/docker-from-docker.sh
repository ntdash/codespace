#! /usr/bin/env bash

USERNAME=${1:-'code'}
DEV_CONFIG_PATH=${2:-'undefined'}
ENABLE_NONROOT_DOCKER=${3:-'true'}

DOCKER_INIT_STUB_PATH="${STUB_PATH}/docker-init.stub"
DCO_ALIAS_STUB_PATH="${STUB_PATH}/dco-alias.stub"


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
      -e "s^\$SOURCE_SOCKET^$SOURCE_SOCKET^g" "${DOCKER_INIT_STUB_PATH}"

else
   echo \
      -e "#!/usr/bin/env bash\n\n# PH_COMPOSE_FILE_BINDER" > "${DOCKER_INIT_STUB_PATH}"
fi

# Try some other method to process the blocks below ... the one used is not optimal

# Empty file if dev config file not defined ...
if [ "$DEV_CONFIG_PATH" != "undefined" ]
then
   sed -i -e "s^\$DEV_CONFIG_PATH^$DEV_CONFIG_PATH^" "${DOCKER_INIT_STUB_PATH}"
else
   echo "" > "${DCO_ALIAS_STUB_PATH}"
fi

sed -i \
   -e "/# PH_COMPOSE_FILE_BINDER/r ${DCO_ALIAS_STUB_PATH}" \
   -e '/# PH_COMPOSE_FILE_BINDER/d' "${DOCKER_INIT_STUB_PATH}"

# remove tmp file
rm -f "${DCO_ALIAS_STUB_PATH}"

# Move processed stub into init.d
mv "${DOCKER_INIT_STUB_PATH}" "${ENTRYPOINT_INIT_D}/docker-init.sh"

echo -e "\nDone!\n"
