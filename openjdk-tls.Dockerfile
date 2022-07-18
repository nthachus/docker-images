ARG TAG=6-jdk-slim
FROM openjdk:${TAG}

ARG JRE_PATH=/jre
ARG BC_VERSION=jdk15to18-163

ADD https://www.bouncycastle.org/download/bcprov-$BC_VERSION.jar \
    https://www.bouncycastle.org/download/bctls-$BC_VERSION.jar "${JAVA_HOME}$JRE_PATH/lib/ext/"

RUN cp -f "${JAVA_HOME}$JRE_PATH/lib/security/java.security" /tmp/ \
 && sed 's/\.[0-9]\+/&./g' /tmp/java.security | \
      awk -F. '/^ *security\.provider\.[0-9]+/{$3=$3+2}{print}' OFS=. | \
      sed -E 's/(\.[0-9]+)\./\1/g' > "${JAVA_HOME}$JRE_PATH/lib/security/java.security" \
 && rm -rf /tmp/* \
 && { \
      echo 'ssl.SocketFactory.provider=org.bouncycastle.jsse.provider.SSLSocketFactoryImpl'; \
      echo 'security.provider.1=org.bouncycastle.jce.provider.BouncyCastleProvider'; \
      echo 'security.provider.2=org.bouncycastle.jsse.provider.BouncyCastleJsseProvider'; \
    } >> "${JAVA_HOME}$JRE_PATH/lib/security/java.security"
