FROM debian:9.9

# Download resources
ADD http://download.bitdefender.com/SMB/Workstation_Security_and_Management/BitDefender_Antivirus_Scanner_for_Unices/Unix/Current/EN_FR_BR_RO/Linux/BitDefender-Antivirus-Scanner-7.6-4.linux-gcc4x.amd64.deb.run \
  https://deb.nodesource.com/gpgkey/nodesource.gpg.key /tmp/

ARG DEBIAN_FRONTEND=noninteractive

# Install & configure dependencies
RUN apt-get update -qq && \
  apt-get install -qy --no-install-recommends apt-utils locales && \
  localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 && \
  apt-get install -qy --no-install-recommends apt-transport-https lsb-release \
   build-essential gnupg zlib1g-dev \
   default-jre-headless \
   postgresql libpq-dev \
   nginx \
   ruby ruby-bundler zip unzip ruby-dev \
   file libarchive13 libmagickwand-dev \
   libreoffice-core libreoffice-writer libreoffice-calc libreoffice-impress && \
  apt-key add /tmp/nodesource.gpg.key && rm -f /tmp/nodesource* && \
  echo "deb https://deb.nodesource.com/node_12.x stretch main" >> /etc/apt/sources.list && \
  apt-get clean && apt-get update -qq && apt-get install -qy --no-install-recommends nodejs && \
  rm -rf /var/lib/apt/lists/* /var/cache/apt/* /var/cache/ldconfig/aux-cache /var/log/apt/*.log && \
  (echo "y" | sh /tmp/BitDefender-Antivirus-Scanner-7.6-4.linux-gcc4x.amd64.deb.run --nox11 --target /tmp/bd/ --nochown --uninstall) && \
  mv /tmp/bd/bitdefender-scanner_7.6-4_amd64.deb ~ && rm -rf /tmp/* && dpkg -i ~/bitdefender-scanner_7.6-4_amd64.deb && \
  rm -rf ~/bitdefender* /tmp/* /var/tmp/* /var/log/*.log && \
  echo "host	all		all		0.0.0.0/0		md5" >> /etc/postgresql/9.6/main/pg_hba.conf && \
  echo "listen_addresses = '*'" >> /etc/postgresql/9.6/main/postgresql.conf

ENV LANG en_US.UTF-8

# Activate BitDefender
ONBUILD RUN echo "accept" | bdscan --info

EXPOSE 5432 80
STOPSIGNAL SIGTERM

# Command to run when starting the container
CMD /etc/init.d/postgresql start ; /usr/sbin/nginx -g "daemon off;"
