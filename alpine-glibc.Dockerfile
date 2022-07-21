ARG  TAG=3.4
FROM alpine:${TAG}

ARG GLIBC_VERSION=2.23-r4
ENV GLIBC_VERSION=$GLIBC_VERSION LANG=C.UTF-8

RUN cd /tmp \
 && apk add --no-cache --virtual=.build-dependencies curl \
 && curl -OkfSL "https://github.com/sgerrand/alpine-pkg-glibc/releases/download/$GLIBC_VERSION/glibc{,-bin,-i18n}-$GLIBC_VERSION.apk" \
 && apk add --no-cache --allow-untrusted /tmp/*.apk \
 && ( /usr/glibc-compat/bin/localedef --force --inputfile POSIX --charmap ${LANG#*.} $LANG || true ) \
 && echo "export LANG=$LANG" > /etc/profile.d/locale.sh \
 && apk del --no-cache .build-dependencies glibc-i18n \
 && rm -rf /var/cache/apk/* /tmp/*
