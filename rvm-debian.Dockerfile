ARG  TAG=stretch-curl
FROM buildpack-deps:${TAG}

ARG DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8

# Install RVM dependencies
RUN sed -i 's~http://archive\(\.ubuntu\.com\)/ubuntu/~mirror://mirrors\1/mirrors.txt~g' /etc/apt/sources.list \
 && apt-get update -qq \
 && apt-get install -qy --no-install-recommends \
      git openssh-client procps \
      patch make gawk \
 && rm -rf /var/cache/apt/* /var/lib/apt/lists/*

# RVM version to install
ARG RVM_VERSION=stable
ENV RVM_VERSION=${RVM_VERSION}

# RMV user to create
# Optional: child images can change to this user, or add 'rvm' group to other user
ARG RVM_USER=rvm
ENV RVM_USER=${RVM_USER}

ARG RVM_AUTOUPDATE=2

# Install RVM
RUN ( curl -ksSL 'https://rvm.io/{mpapis,pkuczynski}.asc' | gpg --quiet --import - ) \
 && ( curl -ksSL https://get.rvm.io | bash -s ${RVM_VERSION} ) \
 && echo "rvm_autoupdate_flag=${RVM_AUTOUPDATE}" >> /etc/rvmrc \
 && echo 'rvm_silence_path_mismatch_check_flag=1' >> /etc/rvmrc \
 && useradd -m --no-log-init -r -g rvm ${RVM_USER} \
 && sed -i 's/^mesg n/tty -s \&\& &/' ~/.profile

# Switch to a bash login shell to allow simple 'rvm' in RUN commands
SHELL ["/bin/bash", "-l", "-c"]
CMD ["/bin/bash", "-l"]

# Optional: child images can set Ruby versions to install (whitespace-separated)
ONBUILD ARG RVM_RUBY_VERSIONS
# Optional: child images can set default Ruby version (default is first version)
ONBUILD ARG RVM_RUBY_DEFAULT

# Child image runs this only if RVM_RUBY_VERSIONS is defined as ARG before the FROM line
ONBUILD RUN if [ -n "${RVM_RUBY_VERSIONS}" ]; then \
              for v in $( echo "${RVM_RUBY_VERSIONS}" | sed -E 's/[[:space:]]+/\n/g' ); do \
                rvm install ${v}; \
              done && \
              rvm use --default "${RVM_RUBY_DEFAULT:-${RVM_RUBY_VERSIONS/[[:space:]]*/}}" && \
              rvm cleanup all && \
              rm -rf /var/cache/apt/* /var/lib/apt/lists/*; \
            fi
