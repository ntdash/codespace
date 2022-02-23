ARG VARIANT="base-devel"
FROM archlinux:${VARIANT}

##################################################################################################################
# Install reflector package
##################################################################################################################

RUN pacman -Sy --noconfirm reflector \
   # Update mirrors list
   && reflector \
   # Update system package
   && pacman -Syyu --noconfirm

##################################################################################################################
# Install needed base tools
##################################################################################################################

RUN pacman -Sy --noconfirm \
   # Basics tool
   git \
   neovim


##################################################################################################################
# Global Settings
##################################################################################################################

ARG USERNAME='code'
ARG UPASSWD='secret'
ARG WORKSPACE_PATH='/wkspace'


ENV SCRIPT_PATH="/tmp/scripts"
ENV STUB_PATH="/tmp/stubs"
ENV CUSTOM_ALIAS_PATH="/home/${USERNAME}/.oh-my-zsh/custom/_aliases.zsh"

##################################################################################################################
# Nonroot user section
##################################################################################################################



ADD ./scripts/setup-user.sh "${SCRIPT_PATH}/"
RUN bash "${SCRIPT_PATH}/setup-user.sh" "${USERNAME}" "${UPASSWD}"

# User custom aliases added after the installation of zsh and OhmyZsh in `setup-user.sh` script
ADD --chown=${USERNAME} ./config/aliases.sh /home/${USERNAME}/.oh-my-zsh/custom/aliases.zsh

##################################################################################################################
# Custom entrypoint Setup
##################################################################################################################

ARG ENTRYPOINT_INIT_PATH="/usr/local/share"
ENV ENTRYPOINT_INIT_D="${ENTRYPOINT_INIT_PATH}/init.d"

ADD ./scripts/init.sh "${ENTRYPOINT_INIT_PATH}/"
RUN mkdir -p "${ENTRYPOINT_INIT_D}" \
   && chmod +x "${ENTRYPOINT_INIT_PATH}/init.sh"

##################################################################################################################
# Docker-from-docker section
##################################################################################################################

ARG DEV_CONFIG_PATH='undefined'
ARG ENABLE_NONROOT_DOCKER='true'

ADD ./stubs/docker-init.stub "${STUB_PATH}/"
ADD ./scripts/docker-from-docker.sh "${SCRIPT_PATH}/"

RUN bash "${SCRIPT_PATH}/docker-from-docker.sh" "${USERNAME}" "${DEV_CONFIG_PATH}" "${ENABLE_NONROOT_DOCKER}"

##################################################################################################################
# Install node suite (nodejs, npm, yarn)
##################################################################################################################

ARG NODE_VERSION='lts'

ADD ./stubs/node-installer.stub "${STUB_PATH}/"
ADD ./scripts/node.sh "${SCRIPT_PATH}/"

RUN bash "${SCRIPT_PATH}/node.sh" "${USERNAME}" "${NODE_VERSION}"

##################################################################################################################
# Resolve paths given as arguments to allow user nonroot after container creation to access it ...
##################################################################################################################

ARG OLIST="${WORKSPACE_PATH}"

ADD ./stubs/ownership-resolver.stub "${STUB_PATH}/"
ADD ./scripts/ownership-resolver.sh "${SCRIPT_PATH}/"
RUN bash "${SCRIPT_PATH}/ownership-resolver.sh" "${USERNAME}" "${OLIST}"

# Allow nonroot user to run custom entrypoint script
RUN chown "${USERNAME}":root "${ENTRYPOINT_INIT_D}" "${ENTRYPOINT_INIT_PATH}/init.sh"

##################################################################################################################
# Entry point
##################################################################################################################

ENTRYPOINT [ "${ENTRYPOINT_INIT_PATH}/init.sh" ]
CMD ["while sleep 1000; do :; done"]
