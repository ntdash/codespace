FROM archlinux:latest

ARG USERNAME='code'
ARG UPASSWD='secret'

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

ADD ./scripts/setup-user.sh /tmp/lib-scripts

RUN bash /tm/lib-scrits/setup-user.sh "${USERNAME}" "${UPASSWD}"
