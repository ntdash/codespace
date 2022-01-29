FROM archlinux:latest

# Install reflector package
RUN pacman -Sy --noconfirm reflector \
   # Update mirrors list
   && reflector \
   # Update system package
   && pacman -Syyu --noconfirm


# Install needed base package
RUN pacman -S --noconfirm \
   # Basics tool
   git \
   sudo \
   neovim \
   # Docker suite
   helm \
   docker \
   kubectl \
   docker-compose \
   # Tools for aur package building
   base-devel

ARG USERNAME='code'
ARG UPASSWD='secret'

ADD ./scripts/setup-user.sh /tmp/scripts/
RUN ls -lAH /tmp/scripts && bash /tmp/scripts/setup-user.sh "${USERNAME}" "${UPASSWD}"
