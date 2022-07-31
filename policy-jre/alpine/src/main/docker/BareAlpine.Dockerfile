FROM alpine

LABEL maintainer="ONAP Integration team, morgan.richomme@orange.com"
LABEL Description="Reference ONAP JAVA 11 image based on alpine"

ENV JAVA_OPTS="-Xms256m -Xmx1g"
ENV JAVA_SEC_OPTS=""

ARG user=onap
ARG group=onap
ARG hello=hello

# Install additional tools and Java
RUN  apk update \
  && apk upgrade \
  && apk add --no-cache openssl ca-certificates \
  && update-ca-certificates \
  && apk add --update coreutils && rm -rf /var/cache/apk/* \
  && apk add --update openjdk11 tzdata curl unzip bash \
  && apk add --no-cache nss \
  && rm -rf /var/cache/apk/*

# Create a group and user
RUN addgroup -S $group && adduser -G $group -D $user && \
    mkdir /var/log/$user && \
    mkdir /app && \
    chown -R $user:$group /var/log/$user && \
    chown -R $user:$group /app && \
    ln -s /usr/bin/java /bin/java

# Tell docker that all future commands should be run as the onap user
USER $user
WORKDIR /app

ENTRYPOINT exec java $JAVA_SEC_OPTS $JAVA_OPTS -jar /app/app.jar
