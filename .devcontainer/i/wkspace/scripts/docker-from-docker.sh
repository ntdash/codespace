#! /usr/bin/env bash

USERNAME=${1:-'code'}
ENABLE_NONROOT_DOCKER=${2:-"true"}


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
   sed -e "s/\$USERNAME/${USERNAME}/g" -e "s/\$TARGET_SOCKET/${TARGET_SOCKET}/g" -e "s/\$SOURCE_SOCKET/${SOURCE_SOCKET}/g" /tmp/docker-init.stub
else
   echo -e "#!/usr/bin/env bash\n\n" > /tmp/docker-init.stub
fi

# Move stub into init.d
mv /tmp/docker-init.stub /usr/local/share/init.d/docker-init.sh

echo -e "\nDone!\n"
