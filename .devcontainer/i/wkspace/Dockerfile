FROM archlinux:latest

# install reflector package
RUN pacman -Sy --noconfirm reflector \
   # update mirrors list
   && reflector \
   # update system package
   && pacman -Syyu --noconfirm


# install needed base package
RUN pacman -S --noconfirm \
   # basics tool
   git \
   sudo \
   neovim \
   # docker suite
   helm \
   docker \
   kubectl \
   docker-compose \
   # tools for aur package building
   base-devel

ARG USERNAME='code'
ARG UPASSWD='secret'

ADD ./scripts/setup-user.sh /tmp/scripts/
RUN ls -lAH /tmp/scripts && bash /tmp/scripts/setup-user.sh "${USERNAME}" "${UPASSWD}"
