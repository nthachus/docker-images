ARG TAG=latest
ARG ARCH=
FROM ${ARCH}alpine:${TAG}

ARG VERSION=11.0.16
ARG PACKAGE=jre-headless

ENV LANG=C.UTF-8 \
    JAVA_VERSION=$VERSION \
    JAVA_HOME=/usr/lib/jvm/default-jvm

RUN apk add --no-cache openjdk${JAVA_VERSION%%[.u]*}${PACKAGE:+-$PACKAGE} \
 && rm -rf /var/cache/apk/* /tmp/*
