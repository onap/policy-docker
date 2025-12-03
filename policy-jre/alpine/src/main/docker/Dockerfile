#   ============LICENSE_START=======================================================
#    Copyright (C) 2019 Tieto. All rights reserved.
#    Modifications Copyright (C) 2020, 2021 AT&T Intellectual Property. All rights reserved.
#    Modifications Copyright (C) 2020, 2022-2025 OpenInfra Foundation Europe. All rights reserved.
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

FROM alpine:3.22.2

LABEL maintainer="Policy Team"
LABEL org.opencontainers.image.title="Policy JRE Alpine"
LABEL org.opencontainers.image.description="Policy Java 21 JRE image based on Alpine"
LABEL org.opencontainers.image.url="https://github.com/onap/policy-docker"
LABEL org.opencontainers.image.vendor="ONAP Policy Team"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.created="${git.build.time}"
LABEL org.opencontainers.image.version="${git.build.version}"
LABEL org.opencontainers.image.revision="${git.commit.id.abbrev}"

ENV JAVA_HOME /usr/lib/jvm/default-jvm
ENV JAVA_OPTS="-Xms256m -Xmx1g"
ENV JAVA_SEC_OPTS=""
ENV POLICY_HOME=/opt/app/policy
ENV PATH $JAVA_HOME/bin:$PATH

ARG user=onap
ARG group=onap

# Default to UTF-8 file.encoding
ENV LANG='en_US.UTF-8' LANGUAGE='en_US:en' LC_ALL='en_US.UTF-8'

# Generic additions
RUN apk update && \
    apk add --no-cache \
        libretls \
        openjdk21-jre \
        openssl && \
    rm -rf /var/cache/apk/* && \
# ONAP additions\
    addgroup -S $group && \
    adduser -G $group -D $user && \
    mkdir /var/log/$user && \
    mkdir /app && \
    chown -R $user:$group /var/log/$user && \
    chown -R $user:$group /app && \
# Policy Framework additions\
    apk update && \
    apk add --no-cache \
        busybox-extras \
        curl \
        jq \
        procps \
        unzip \
        zip && \
    rm -rf /var/cache/apk/* && \
    addgroup -S policy && \
    adduser -S  --shell /bin/sh -G policy policy && \
    mkdir -p ${POLICY_HOME}/ && \
    chown policy:policy ${POLICY_HOME} && \
    mkdir -p /usr/lib/jvm/ && \
    ln -s /opt/java/openjdk /usr/lib/jvm/default-jvm

# Tell docker that all future commands should be run as the onap user
USER $user
WORKDIR /app

ENTRYPOINT exec java $JAVA_SEC_OPTS $JAVA_OPTS -jar /app/app.jar
