# args and export for script runtime

export NVM_DIR="/usr/local/share/nvm"
export NODE_VERSION=${2:-"lts"}
USERNAME=${1:-'code'}
export NVM_VERSION="0.38.0"

# Helpers

updaterc() {

   if [ "${USERNAME}" = "root" ]
   then
      local user_rc_path="/root"
   else
      local user_rc_path="/home/${USERNAME}"
   fi

   echo "Updating "${user_rc_path}.bashrc" and "${user_rc_path}.zshrc"..."

   if [[ "$(cat ${user_rc_path}/.bashrc)" != *"$1"* ]]
   then
      echo -e "\n\n$1" >> "${user_rc_path}/.bashrc"
   fi

   if [[ "$(cat ${user_rc_path}/.zshrc)" != *"$1"* ]]
   then
      echo -e "\n\n$1" >> "${user_rc_path}/.zshrc"
   fi
}


# Install node and npm via nvm

if [ "${NODE_VERSION}" = "none" ]
then
   export NODE_VERSION=
elif [ "${NODE_VERSION}" = "lts" ]
then
   export NODE_VERSION="lts/*"
fi


if ! cat /etc/group | grep -e "^nvm:" > /dev/null 2>&1
then
   groupadd -r nvm
fi

umask 0002
usermod -a -G nvm ${USERNAME}
mkdir -p ${NVM_DIR}
chown :nvm ${NVM_DIR}
chmod g+s ${NVM_DIR}
su ${USERNAME} -c "bash ${STUB_PATH}/node-installer.stub" 2>&1

# Update bash and zsh `rc` files

updaterc "$(cat <<EOF
   export NVM_DIR="$NVM_DIR"
   [ -s "\$NVM_DIR/nvm.sh" ] && . "\$NVM_DIR/nvm.sh"
   [ -s "\$NVM_DIR/bash_completion" ] && . "\$NVM_DIR/bash_completion"
EOF
)"

echo -e "\nDone!\n"
