# args and export for script runtime

export NVM_DIR="/usr/local/share/nvm"
export NODE_VERSION=${2:-"lts"}
USERNAME=${1:-'code'}
export NVM_VERSION="0.38.0"

# fucntion

updaterc() {

   if [ "${USERNAME}" = "root" ]; then
      local user_rc_path="/root"
   else
      local user_rc_path="/home/${USERNAME}"
   fi

   echo "Updating /home/${USERNAME}/.bashrc and /home/${USERNAME}/.zshrc..."
   if [[ "$(cat /home/${USERNAME}/.bashrc)" != *"$1"* ]]; then
      echo -e "$1" >> "/home/${USERNAME}/.bashrc"
   fi
   if [ -f "/home/${USERNAME}/.zshrc" ] && [[ "$(cat /home/${USERNAME}/.zshrc)" != *"$1"* ]]; then
      echo -e "$1" >> "/home/${USERNAME}/.zshrc"
   fi
}

# install node and npm via nvm

if ! cat /etc/group | grep -e "^nvm:" > /dev/null 2>&1; then
    groupadd -r nvm
fi
umask 0002
usermod -a -G nvm ${USERNAME}
mkdir -p ${NVM_DIR}
chown :nvm ${NVM_DIR}
chmod g+s ${NVM_DIR}
su ${USERNAME} -c "$(cat << EOF
    set -e
    umask 0002
    # Do not update profile - we'll do this manually
    export PROFILE=/dev/null
    curl -so- https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh | bash
    source ${NVM_DIR}/nvm.sh
    if [ "${NODE_VERSION}" != "" ]; then
        nvm alias default ${NODE_VERSION}
    fi
    nvm clear-cache
EOF
)" 2>&1

# update bash and zsh `rc` files
updaterc "$(cat <<EOF
export NVM_DIR="${NVM_DIR}"
[ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && . "\$NVM_DIR/bash_completion"
EOF
)"

# install yarn
if type yarn > /dev/null 2>&1; then
    echo "Yarn already installed."
else
   pacman -Sy --noconfirm yarn
fi
