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
ARG WORKDIR='/wkspace'

ADD ./scripts/setup-user.sh /tmp/scripts/
RUN bash /tmp/scripts/setup-user.sh "${USERNAME}" "${UPASSWD}"

# Custom entrypoint Setup
ADD ./scripts/init.sh /usr/local/share/
RUN mkdir -p /usr/local/share/init.d \
   && chmod +x /usr/local/share/init.sh

# Resolve paths given as arguments to allow user nonroot after container creation to access it ...
ADD ./scripts/ownership-resolver.sh /tmp/scripts/
RUN bash /tmp/scripts/ownership-resolver.sh "${USERNAME}" "${WORKDIR}"

# Allow nonroot user to run custom entrypoint script
RUN chown "${USERNAME}":root /usr/local/share/init.d /usr/local/share/init.sh

ENTRYPOINT [ "/usr/local/share/init.sh" ]
CMD ["while sleep 1000; do :; done"]
