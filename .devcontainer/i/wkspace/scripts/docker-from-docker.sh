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
# Otherwise stop current script
if [ "${ENABLE_NONROOT_DOCKER}" != "true" ];
then
   echo "\nDone!\n"
   exit 0
fi

# Enabling docker usage to nonroot user
chown -h "${USERNAME}":root "${TARGET_SOCKET}"

pacman -Sy --noconfirm socat

tee /usr/local/share/init.d/docker-init.sh > /dev/null \
<< EOF
#!/usr/bin/env bash

set -e

SOCAT_PATH_BASE=/tmp/vscr-docker-from-docker
SOCAT_LOG=\${SOCAT_PATH_BASE}.log
SOCAT_PID=\${SOCAT_PATH_BASE}.pid

# Wrapper function to only use sudo if not already root
sudoIf()
{
   if [ "\$(id -u)" -ne 0 ]; then
      sudo "\$@"
   else
      "\$@"
   fi
}

# Log messages
log()
{
   echo -e "[\$(date)] \$@" | sudoIf tee -a \${SOCAT_LOG} > /dev/null
}

echo -e "\n** \$(date) **" | sudoIf tee -a \${SOCAT_LOG} > /dev/null
log "Ensuring ${USERNAME} has access to ${SOURCE_SOCKET} via ${TARGET_SOCKET}"

# If enabled, try to add a docker group with the right GID. If the group is root,
# fall back on using socat to forward the docker socket to another unix socket so
# that we can set permissions on it without affecting the host.
if [ "${ENABLE_NONROOT_DOCKER}" = "true" ] && [ "${SOURCE_SOCKET}" != "${TARGET_SOCKET}" ] && [ "${USERNAME}" != "root" ] && [ "${USERNAME}" != "0" ]; then
   SOCKET_GID=\$(stat -c '%g' ${SOURCE_SOCKET})
   if [ "\${SOCKET_GID}" != "0" ]; then
      log "Adding user to group with GID \${SOCKET_GID}."
      if [ "\$(cat /etc/group | grep :\${SOCKET_GID}:)" = "" ]; then
         sudoIf groupadd --gid \${SOCKET_GID} docker-host
      fi
      # Add user to group if not already in it
      if [ "\$(id ${USERNAME} | grep -E "groups.*(=|,)\${SOCKET_GID}\(")" = "" ]; then
         sudoIf usermod -aG \${SOCKET_GID} ${USERNAME}
      fi
   else
      # Enable proxy if not already running
      if [ ! -f "\${SOCAT_PID}" ] || ! ps -p \$(cat \${SOCAT_PID}) > /dev/null; then
            log "Enabling socket proxy."
            log "Proxying ${SOURCE_SOCKET} to ${TARGET_SOCKET} for vscode"
            sudoIf rm -rf ${TARGET_SOCKET}
            (sudoIf socat UNIX-LISTEN:${TARGET_SOCKET},fork,mode=660,user=${USERNAME} UNIX-CONNECT:${SOURCE_SOCKET} 2>&1 | sudoIf tee -a \${SOCAT_LOG} > /dev/null & echo "\$!" | sudoIf tee \${SOCAT_PID} > /dev/null)
      else
            log "Socket proxy already running."
      fi
   fi
   log "Success"
fi

set +e
EOF

echo -e "\nDone!\n"
