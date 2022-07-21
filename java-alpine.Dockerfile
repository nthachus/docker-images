ARG TAG=2.23
ARG JAVA_PACKAGE=jdk
ARG JAVA_VERSION=6u45

FROM nthachus/alpine-glibc:${TAG}
ARG JAVA_PACKAGE
ARG JAVA_VERSION

ADD $JAVA_PACKAGE-${JAVA_VERSION}_linux-x64_bin.tar.gz /opt

RUN ln -sf /opt/$JAVA_PACKAGE* /opt/$JAVA_PACKAGE \
 && ( [ ! -e /opt/jdk/jre ] || ln -sf /opt/jdk/jre /opt/jre ) \
 && rm -rf /opt/jdk/*src.zip \
           /opt/jdk/bin/*visualvm* \
           /opt/jdk/lib/missioncontrol \
           /opt/jdk/lib/visualvm \
           /opt/jdk/lib/*javafx* \
           /opt/jdk/db \
           /opt/$JAVA_PACKAGE/man \
           /opt/jre/plugin \
           /opt/jre/bin/javaws \
           /opt/jdk/jre/bin/jjs \
           /opt/jdk/jre/bin/orbd \
           /opt/jdk/jre/bin/pack200 \
           /opt/jdk/jre/bin/policytool \
           /opt/jdk/jre/bin/rmid \
           /opt/jdk/jre/bin/rmiregistry \
           /opt/jdk/jre/bin/servertool \
           /opt/jdk/jre/bin/tnameserv \
           /opt/jdk/jre/bin/unpack200 \
           /opt/jre/lib/javaws.jar \
           /opt/jre/lib/deploy* \
           /opt/jre/lib/desktop \
           /opt/jre/lib/*javafx* \
           /opt/jre/lib/*jfx* \
           /opt/jre/lib/amd64/libdecora_sse.so \
           /opt/jre/lib/amd64/libprism_*.so \
           /opt/jre/lib/amd64/libfxplugins.so \
           /opt/jre/lib/amd64/libglass.so \
           /opt/jre/lib/amd64/libgstreamer-lite.so \
           /opt/jre/lib/amd64/libjavafx*.so \
           /opt/jre/lib/amd64/libjfx*.so \
           /opt/jre/lib/ext/jfxrt.jar \
           /opt/jre/lib/ext/nashorn.jar \
           /opt/jre/lib/oblique-fonts \
           /opt/jre/lib/plugin.jar

# Multi-stage builds
FROM nthachus/alpine-glibc:${TAG}
ARG JAVA_PACKAGE
ARG JAVA_VERSION

COPY --from=0 /opt /opt

ENV JAVA_VERSION=$JAVA_VERSION \
    JAVA_HOME=/opt/$JAVA_PACKAGE \
    PATH=${PATH}:/opt/$JAVA_PACKAGE/bin
