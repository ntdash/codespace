#! /usr/bin/env bash

USERNAME=${1:-'code'}
UPASSWD=${2:-'secret'}

# Create non-root user
useradd -mp "${UPASSWD}" "${USERNAME}"

# Grant root privilege to the newly created non-root user

# Install sudo if not already install
if  ! type sudo > /dev/null 2>&1; then
   pacman -Sy --noconfirm sudo
fi

echo ${USERNAME} ALL=\(ALL\) ALL > /etc/sudoers.d/${USERNAME}
chmod 0440 /etc/sudoers.d/${USERNAME}

# Add basics groups to it
usermod -aG optical,storage "${USERNAME}"


# Install zsh and change the newly created user's default shell

# Install zsh
pacman -Sy --noconfirm zsh

# Install ohmyzsh
su ${USERNAME} -c 'bash -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended'

# Enable docker and docker-compose plugin in zshrc
sed -i -r 's/^plugins=\((.*)\)$/plugins=\(\1 docker docker-compose\)/' /home/${USERNAME}/.zshrc

# custom aliases
tee "${CUSTOM_ALIAS_PATH}" > /dev/null <<EOF
#! /usr/bin/env zsh

# Here contain custom alias for easy/fast command typing and workflow resolvance

EOF

# Change user default shell into zsh
usermod -s /usr/bin/zsh "${USERNAME}"
