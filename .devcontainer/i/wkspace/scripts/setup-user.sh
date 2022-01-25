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
