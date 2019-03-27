#
# Docker file to build a base image for all policy apps images
# 
# $JAVA_HOME is set to /usr/lib/jvm/java-1.8-openjdk
# more details at https://hub.docker.com/_/openjdk
#
FROM openjdk:8-alpine

LABEL maintainer="Policy Team"

# used in 7 out of 7 images
RUN apk add --no-cache \
    bash \
    coreutils \
    curl \
    findutils \
    grep \
    nss \
    openssh \
    procps \
    unzip \
    wget \
    zip
