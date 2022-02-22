ARG VARIANT="base-devel"
FROM archlinux:${VARIANT}

# Install reflector package
RUN pacman -Sy --noconfirm reflector \
   # Update mirrors list
   && reflector \
   # Update system package
   && pacman -Syyu --noconfirm

# Install needed base tools
RUN pacman -Sy --noconfirm \
   # Basics tool
   git \
   neovim

# Nonroot user section
ARG USERNAME='code'
ARG UPASSWD='secret'
ARG WORKSPACE_PATH='/wkspace'

ENV CUSTOM_ALIAS_PATH="/home/${USERNAME}/.oh-my-zsh/custom/__aliases.zsh"

ADD ./scripts/setup-user.sh /tmp/scripts/
RUN bash /tmp/scripts/setup-user.sh "${USERNAME}" "${UPASSWD}"

# User custom aliases added after the installation of zsh and OhmyZsh in `setup-user.sh` script
ADD --chown=${USERNAME} ./config/aliases.sh /home/${USERNAME}/.oh-my-zsh/custom/aliases.zsh

# Custom entrypoint Setup
ADD ./scripts/init.sh /usr/local/share/
RUN mkdir -p /usr/local/share/init.d \
   && chmod +x /usr/local/share/init.sh

# Docker-from-docker section
ARG DEV_CONFIG_PATH='undefined'
ARG ENABLE_NONROOT_DOCKER='true'

ADD ./stubs/docker-init.stub ./scripts/docker-from-docker.sh /tmp/scripts/
RUN bash /tmp/scripts/docker-from-docker.sh "${USERNAME}" "${DEV_CONFIG_PATH}" "${ENABLE_NONROOT_DOCKER}"

# Install node suite (nodejs, npm, yarn)
ARG NODE_VERSION='lts'

ADD ./stubs/node-installer.stub ./stubs/nvm-loader.stub ./scripts/node.sh /tmp/scripts/
RUN bash /tmp/scripts/node.sh "${USERNAME}" "${NODE_VERSION}"

# Resolve paths given as arguments to allow user nonroot after container creation to access it ...
ARG OLIST="${WORKSPACE_PATH}"

ADD ./stubs/ownership-resolver.stub ./scripts/ownership-resolver.sh /tmp/scripts/
RUN bash /tmp/scripts/ownership-resolver.sh "${USERNAME}" "${OLIST}"

# Allow nonroot user to run custom entrypoint script
RUN chown "${USERNAME}":root /usr/local/share/init.d /usr/local/share/init.sh

ENTRYPOINT [ "/usr/local/share/init.sh" ]
CMD ["while sleep 1000; do :; done"]
