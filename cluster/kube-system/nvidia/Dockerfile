FROM archlinux:latest

RUN pacman -Sy curl gcc kmod make --noconfirm

COPY entrypoint.sh /entrypoint.sh

CMD /entrypoint.sh
