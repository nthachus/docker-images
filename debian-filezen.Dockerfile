FROM debian:9.9
MAINTAINER Thach Nguyen <nthachus@gmail.com>

ARG DEBIAN_FRONTEND=noninteractive

# Install & configure dependencies
RUN echo "deb http://deb.nodesource.com/node_12.x stretch main" >> /etc/apt/sources.list \
 && apt-get update -qq \
 && apt-get install -qy --no-install-recommends --allow-unauthenticated locales \
  build-essential zlib1g-dev \
  postgresql libpq-dev \
  nginx \
  nodejs \
  ruby ruby-bundler ruby-dev \
  file libarchive13 libmagickwand-dev \
  libreoffice-core libreoffice-writer libreoffice-calc libreoffice-impress \
  rsyslog \
 && rm -rf /tmp/* /var/log/*.log /var/lib/apt/lists/* /var/cache/apt/* /var/cache/ldconfig/aux-cache /var/log/apt/*.log \
 && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
 && echo "host	all		all		0.0.0.0/0		md5" >> /etc/postgresql/9.6/main/pg_hba.conf \
 && echo "listen_addresses = '*'" >> /etc/postgresql/9.6/main/postgresql.conf

ENV LANG en_US.UTF-8

EXPOSE 5432 80
STOPSIGNAL SIGTERM

# Command to run when starting the container
CMD /etc/init.d/postgresql start ; /usr/sbin/nginx -g "daemon off;"
