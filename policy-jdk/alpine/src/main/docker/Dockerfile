#   ============LICENSE_START=======================================================
#    Copyright (C) 2019 Tieto. All rights reserved.
#    Modifications Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
#   ================================================================================
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   SPDX-License-Identifier: Apache-2.0
#   ============LICENSE_END=========================================================

# Docker file to build a base image for all policy components images
#
# $JAVA_HOME is set to /usr/lib/jvm/java-11-openjdk
# more details at https://hub.docker.com/_/openjdk

FROM alpine:latest

LABEL maintainer="Policy Team"

ARG BUILD_VERSION=${BUILD_VERSION}
ARG MAVEN_VERSION=3.6.3
ARG SHA=c35a1803a6e70a126e80b2b3ae33eed961f83ed74d18fcd16909b2d44d7dada3203f1ffe726c17ef8dcca2dcaa9fca676987befeadc9b9f759967a8cb77181c0
ARG BASE_URL=https://apache.osuosl.org/maven/maven-3/${MAVEN_VERSION}/binaries

ENV BUILD_VERSION ${BUILD_VERSION}
ENV POLICY_HOME=/opt/app/policy

RUN apk update \
    && apk add --no-cache \
        bash \
        busybox-extras \
        coreutils \
        curl \
        findutils \
        grep \
        httpie \
        jq \
        nss \
        openjdk11 \
        openssh \
        procps \
        py-pip \
        python \
        unzip \
        wget \
        zip \
    && mkdir -p /usr/share/maven /usr/share/maven/ref \
    && curl -fsSL -o /tmp/apache-maven.tar.gz \
        ${BASE_URL}/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && echo "${SHA} /tmp/apache-maven.tar.gz" | sha512sum -c - \
    && tar -xzf /tmp/apache-maven.tar.gz -C /usr/share/maven \
        --strip-components=1 \
    && rm -f /tmp/apache-maven.tar.gz \
    && ln -s /usr/share/maven/bin/mvn /usr/bin/mvn \
    && addgroup -S policy \
    && adduser -S  --shell /bin/bash -G policy policy \
    && mkdir -p ${POLICY_HOME}/etc/ssl \
    && chown -R policy:policy ${POLICY_HOME}
