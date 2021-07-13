#   ============LICENSE_START=======================================================
#    Copyright (C) 2019 Tieto. All rights reserved.
#    Modifications Copyright (C) 2020, 2021 AT&T Intellectual Property. All rights reserved.
#    Modifications Copyright (C) 2020 Nordix Foundation.
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

FROM adoptopenjdk/openjdk11:x86_64-alpine-jdk-11.0.11_9

LABEL maintainer="Policy Team"

ENV JAVA_OPTS="-Xms256m -Xmx1g"
ENV JAVA_SEC_OPTS=""
ENV POLICY_HOME=/opt/app/policy

# Install additional tools
RUN apk update \
    && apk add --no-cache \
        busybox-extras \
        curl \
        jq \
        procps \
        unzip \
        zip \
    && curl --fail --silent --show-error --retry 3 \
            --output /tmp/apache-maven-3.6.3-bin.tar.gz \
            https://downloads.apache.org/maven/maven-3/3.6.3/binaries/apache-maven-3.6.3-bin.tar.gz \
    && tar zxC /usr/share </tmp/apache-maven-3.6.3-bin.tar.gz \
    && chown -R root:root /usr/share/apache-maven-3.6.3 \
    && ln -s /usr/share/apache-maven-3.6.3/bin/mvn /usr/bin/mvn \
    && rm -f /tmp/apache-maven-3.6.3-bin.tar.gz \
    && addgroup -S policy \
    && adduser -S --shell /bin/sh -G policy policy \
    && mkdir -p /var/log/onap/policy \
    && chown policy:policy /var/log/onap/policy \
    && mkdir -p ${POLICY_HOME} \
    && chown policy:policy ${POLICY_HOME} \
    && mkdir -p /usr/lib/jvm/ \
    && ln -s /opt/java/openjdk /usr/lib/jvm/java-11-openjdk
