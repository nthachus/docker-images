FROM buildpack-deps:stretch-curl

# RVM version & user to install
ARG rvm_version=stable
ARG rvm_user=rvm

ENV LANG C.UTF-8

# Install RVM dependencies
RUN sed -i 's~http://archive\(\.ubuntu\.com\)/ubuntu/~mirror://mirrors\1/mirrors.txt~g' /etc/apt/sources.list \
 && apt-get update -qq && apt-get install -qy --no-install-recommends \
  git openssh-client procps \
  patch make gawk \
 && rm -rf /var/lib/apt/lists/*

# Install RVM
RUN mkdir ~/.gnupg && chmod 700 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf \
 && gpg --quiet --no-tty --keyserver hkp://pool.sks-keyservers.net \
  --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB \
 && ( curl -sSL https://get.rvm.io | bash -s ${rvm_version} ) \
 && echo "rvm_autoupdate_flag=2" >> /etc/rvmrc \
 && echo "rvm_silence_path_mismatch_check_flag=1" >> /etc/rvmrc \
 && echo "install: --no-document" > /etc/gemrc \
 && useradd -m --no-log-init -r -g rvm ${rvm_user} \
 && sed -i 's/^mesg n/tty -s \&\& &/' ~/.profile

# Switch to a bash login shell to allow simple 'rvm' in RUN commands
SHELL ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash", "-l"]

# Child images can set Ruby versions to install (whitespace-separated) and default version to run
ONBUILD ARG ruby_versions
ONBUILD ARG ruby_default

# Child image runs this only if `ruby_versions` is defined as ARG before the FROM line
ONBUILD RUN if [ ! -z "${ruby_versions}" ]; then \
  for v in $( echo "${ruby_versions}" | sed -E 's/[[:space:]]+/\n/g' ); do \
   rvm install ${v}; \
  done \
  && rvm cleanup all \
  && rm -rf /var/lib/apt/lists/*; \
 fi
ONBUILD RUN if [ ! -z "${ruby_versions}" ]; then \
  rvm use --default "${ruby_default:-${ruby_versions/[[:space:]]*/}}"; \
 fi
