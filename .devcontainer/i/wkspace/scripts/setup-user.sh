#! /usr/bin/env bash

USERNAME=${1:-'code'}
UPASSWD=${2:-'secret'}

echo -e "\nCreating a new user with root permission with the following credentials:\nusername: $USERNAME\npassword: $UPASSWD...\n\n"

# create non-root user
useradd -mp "${UPASSWD}" "${USERNAME}"

# grant root privilege to the newly created non-root user
echo ${USERNAME} ALL=\(ALL\) ALL > /etc/sudoers.d/${USERNAME}
chmod 0440 /etc/sudoers.d/${USERNAME}

# add basics groups to it
usermod -aG optical,docker,storage "${USERNAME}"


# install zsh and change the newly created user's default shell

# install zsh
pacman -S --noconfirm zsh

# install ohmyzsh
su ${USERNAME} -c 'bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# enable docker and docker-compose plugin in zshrc
sed -i -r 's/^plugins=\((.*)\)$/plugins=\(\1 docker docker-compose\)/' /home/${USERNAME}/.zshrc

# change user default shell into zsh
usermod -s /usr/bin/zsh "${USERNAME}"
