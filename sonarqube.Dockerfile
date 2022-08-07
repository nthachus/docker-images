ARG  TAG=3.15
FROM alpine:${TAG}

ARG VERSION=9.5.0.56709
ARG DIST_PATH=Distribution/sonarqube/sonarqube
ARG JAVA_VERSION=11

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8 \
    JAVA_HOME=/usr/lib/jvm/default-jvm \
    SONARQUBE_HOME=/opt/sonarqube \
    SONAR_VERSION=$VERSION

# MB: 499 534
RUN apk add --no-cache bash su-exec openjdk${JAVA_VERSION}-jre ttf-dejavu \
 && apk add --no-cache --virtual .build-dependencies curl unzip \
 && echo 'networkaddress.cache.ttl=5' >> "${JAVA_HOME}/conf/security/java.security" \
 && sed -i 's|\(securerandom.source=file:/dev\)/random|\1/urandom|' "${JAVA_HOME}/conf/security/java.security" \
  #
 && curl -o /tmp/sonarqube.zip -kfSL "https://binaries.sonarsource.com/${DIST_PATH}-${SONAR_VERSION}.zip" \
 && mkdir -p /opt \
 && unzip -q /tmp/sonarqube.zip -d /opt \
 && ln -s $( basename ${SONARQUBE_HOME}-* ) ${SONARQUBE_HOME} \
 && rm -rf ${SONARQUBE_HOME}/bin/* /tmp/* \
  #
 && { echo '#!/bin/sh'; \
      echo 'java -jar "$(dirname "$0")/../lib"/sonar-application-*.jar -Dsonar.log.console=true "$@"'; \
    } > ${SONARQUBE_HOME}/bin/sonar.sh \
 && chmod +x ${SONARQUBE_HOME}/bin/*.sh \
  #
 && addgroup -S -g 1000 sonarqube \
 && adduser -S -D -H -h ${SONARQUBE_HOME} -g SonarQube -u 1000 -G sonarqube sonarqube \
 && chown -R sonarqube:sonarqube ${SONARQUBE_HOME}-* \
 && chmod -R 700 ${SONARQUBE_HOME}/data ${SONARQUBE_HOME}/extensions ${SONARQUBE_HOME}/logs ${SONARQUBE_HOME}/temp \
  #
 && apk del --no-cache --purge .build-dependencies \
 && rm -rf /var/cache/apk/* /tmp/*

EXPOSE 9000
STOPSIGNAL SIGINT

WORKDIR ${SONARQUBE_HOME}
VOLUME ["${SONARQUBE_HOME}/data", "${SONARQUBE_HOME}/extensions", "${SONARQUBE_HOME}/logs"]

ENTRYPOINT ["su-exec", "sonarqube", "/opt/sonarqube/bin/sonar.sh"]
CMD ["-Dsonar.telemetry.enable=false"]
