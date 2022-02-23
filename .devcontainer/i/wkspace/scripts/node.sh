# args and export for script runtime

export NVM_DIR="/usr/local/share/nvm"
export NODE_VERSION=${2:-"--lts"}
USERNAME=${1:-'code'}
export NVM_VERSION="0.38.0"

# Helpers

updaterc() {

   local content
   read content

   if [ "${USERNAME}" = "root" ]
   then
      local user_rc_path="/root"
   else
      local user_rc_path="/home/${USERNAME}"
   fi

   echo "Updating /home/${USERNAME}/.bashrc and /home/${USERNAME}/.zshrc..."

   if [[ "$(cat /home/${USERNAME}/.bashrc)" != *"$content"* ]]
   then
      echo -e "\n$content" >> "/home/${USERNAME}/.bashrc"
   fi

   if [[ "$(cat /home/${USERNAME}/.zshrc)" != *"$content"* ]]
   then
      echo -e "\n$content" >> "/home/${USERNAME}/.zshrc"
   fi
}

# Install node and npm via nvm

if ! cat /etc/group | grep -e "^nvm:" > /dev/null 2>&1
then
   groupadd -r nvm
fi

umask 0002
usermod -a -G nvm ${USERNAME}
mkdir -p ${NVM_DIR}
chown :nvm ${NVM_DIR}
chmod g+s ${NVM_DIR}
su ${USERNAME} -c "bash /tmp/scripts/node-installer.stub" 2>&1

# Update bash and zsh `rc` files
sed \
   -e "s:\$NVM_DIR:$NVM_DIR:" /tmp/scripts/nvm-loader.stub | updaterc

# Install yarn
if type yarn > /dev/null 2>&1; then
    echo "Yarn already installed."
else
   pacman -Sy --noconfirm yarn
fi

echo -e "\nDone!\n"
