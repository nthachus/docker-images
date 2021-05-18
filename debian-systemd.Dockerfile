ARG  TAG=stable-slim
FROM debian:${TAG}

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG C.UTF-8
ENV container docker

RUN apt-get update -qq \
 && apt-get install -qy --no-install-recommends \
  systemd systemd-sysv \
 && rm -rf /var/cache/apt/* /var/lib/apt/lists/* /tmp/*

RUN rm -f \
  /etc/systemd/system/*.wants/* \
  /lib/systemd/system/multi-user.target.wants/* \
  /lib/systemd/system/local-fs.target.wants/* \
  /lib/systemd/system/sockets.target.wants/*udev* \
  /lib/systemd/system/sockets.target.wants/*initctl* \
  /lib/systemd/system/systemd-update-utmp* \
  /lib/systemd/system/*.wants/systemd-update-utmp* \
 && find /lib/systemd/system/sysinit.target.wants/ ! -type d ! -name 'systemd-tmpfiles-setup*' -delete

STOPSIGNAL SIGRTMIN+3
VOLUME ["/sys/fs/cgroup"]

CMD ["/sbin/init"]
