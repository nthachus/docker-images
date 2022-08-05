ARG TAG=7-jdk-alpine
ARG M2_VERSION=3.2.5

FROM openjdk:${TAG}

ARG M2_VERSION
ADD https://archive.apache.org/dist/maven/maven-3/$M2_VERSION/binaries/apache-maven-$M2_VERSION-bin.tar.gz /tmp/

RUN tar -C /usr/share -xf /tmp/apache-maven-*.tar.gz \
 && mv /usr/share/apache-maven-* /usr/share/maven
# RUN sed -i 's,</profiles>,  <profile>\n      <id>maven-https</id>\n      <activation><activeByDefault>true</activeByDefault></activation>\n      <repositories>\n        <repository>\n          <id>central</id>\n          <url>https://repo.maven.apache.org/maven2</url>\n          <snapshots><enabled>false</enabled></snapshots>\n        </repository>\n      </repositories>\n      <pluginRepositories>\n        <pluginRepository>\n          <id>central</id>\n          <url>https://repo.maven.apache.org/maven2</url>\n          <snapshots><enabled>false</enabled></snapshots>\n          <releases><updatePolicy>never</updatePolicy></releases>\n        </pluginRepository>\n      </pluginRepositories>\n    </profile>  &,' /usr/share/maven/conf/settings.xml

# Multi-stage builds
FROM openjdk:${TAG}

ARG M2_VERSION
ENV MAVEN_VERSION=$M2_VERSION M2_HOME=/usr/share/maven

COPY --from=0 $M2_HOME $M2_HOME
RUN ln -s $M2_HOME/bin/mvn /usr/local/bin/

CMD ["mvn", "-v"]
