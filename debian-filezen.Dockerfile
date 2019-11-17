# the base image
FROM debian:9.9

# update sources list
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq
RUN apt-get install -qy apt-utils

# Use en_US.UTF-8 as our locale
RUN apt-get install -qy --no-install-recommends locales
RUN localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.UTF-8

# install basic apps, one per line for better caching
RUN apt-get install -qy lsb-release
RUN apt-get install -qy --no-install-recommends build-essential gnupg zlib1g-dev
RUN apt-get install -qy default-jre-headless

# RUN apt-get install -qy --no-install-recommends git
RUN apt-get install -qy subversion

# install runtime apps
RUN apt-get install -qy --no-install-recommends postgresql libpq-dev
RUN apt-get install -qy --no-install-recommends nginx
RUN apt-get install -qy --no-install-recommends ruby ruby-bundler zip unzip ruby-dev

# install runtime dependencies
RUN apt-get install -qy --no-install-recommends libarchive13
RUN apt-get install -qy --no-install-recommends libmagick++-dev
RUN apt-get install -qy --no-install-recommends libreoffice-core libreoffice-writer libreoffice-calc libreoffice-impress

# RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
ADD https://deb.nodesource.com/gpgkey/nodesource.gpg.key /tmp/
RUN apt-key add /tmp/nodesource.gpg.key
RUN echo "deb https://deb.nodesource.com/node_12.x stretch main" > /etc/apt/sources.list.d/nodesource.list && \
  echo "deb-src https://deb.nodesource.com/node_12.x stretch main" >> /etc/apt/sources.list.d/nodesource.list

RUN apt-get install -qy apt-transport-https
RUN apt-get clean && apt-get update -qq
RUN apt-get install -qy --no-install-recommends nodejs

# install BitDefender
ADD http://download.bitdefender.com/SMB/Workstation_Security_and_Management/BitDefender_Antivirus_Scanner_for_Unices/Unix/Current/EN_FR_BR_RO/Linux/BitDefender-Antivirus-Scanner-7.6-4.linux-gcc4x.amd64.deb.run /tmp/
RUN echo "y" | sh /tmp/BitDefender-Antivirus-Scanner-7.6-4.linux-gcc4x.amd64.deb.run --nox11 --target /tmp/bd/ --nochown --uninstall
RUN rm -rf /tmp/*.* && apt-get install -qy /tmp/bd/bitdefender-scanner_7.6-4_amd64.deb

# cleanup
RUN apt-get purge -qy --auto-remove apt-transport-https apt-utils
RUN rm -rf /tmp/* /var/tmp/* /var/cache/apt/* /var/lib/apt/lists/* /var/cache/ldconfig/aux-cache /var/log/*.log /var/log/apt/*.log

# adjust configurations
RUN echo "host	all		all		0.0.0.0/0		md5" >> /etc/postgresql/9.6/main/pg_hba.conf && \
  echo "listen_addresses = '*'" >> /etc/postgresql/9.6/main/postgresql.conf && \
  sed -i "s/# gzip_/gzip_/" /etc/nginx/nginx.conf

# expose ports
EXPOSE 5432 80 443

# add VOLUMEs to allow backup of config, logs and databases
VOLUME ["/etc/postgresql", "/var/log/postgresql", "/var/lib/nginx", "/var/log/nginx"]

# command to run when starting the container
STOPSIGNAL SIGTERM
CMD /etc/init.d/postgresql start ; /usr/sbin/nginx -g "daemon off;"
