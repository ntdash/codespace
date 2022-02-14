#! /usr/bin/env bash

USERNAME=${1:-'code'}
UPASSWD=${2:-'secret'}

# Create non-root user
useradd -mp "${UPASSWD}" "${USERNAME}"

# Grant root privilege to the newly created non-root user
echo ${USERNAME} ALL=\(ALL\) ALL > /etc/sudoers.d/${USERNAME}
chmod 0440 /etc/sudoers.d/${USERNAME}

# Add basics groups to it
usermod -aG optical,storage "${USERNAME}"


# Install zsh and change the newly created user's default shell

# Install zsh
pacman -S --noconfirm zsh

# Install ohmyzsh
su ${USERNAME} -c 'bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Enable docker and docker-compose plugin in zshrc
sed -i -r 's/^plugins=\((.*)\)$/plugins=\(\1 docker docker-compose\)/' /home/${USERNAME}/.zshrc

# Change user default shell into zsh
usermod -s /usr/bin/zsh "${USERNAME}"
