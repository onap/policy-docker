#   ============LICENSE_START=======================================================
#    Copyright (C) 2020 AT&T Intellectual Property. All rights reserved.
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

FROM openjdk:11.0.5-jre-slim

LABEL maintainer="Policy Team"

ENV POLICY_HOME=/opt/app/policy

RUN apt-get -y update \
    && apt-get -y install \
        curl \
        httpie \
        jq \
        less \
        python \
        python-pip \
        ssh \
        unzip \
        wget \
        zip \
    && mkdir /usr/lib/jvm \
    && ln -s /usr/local/openjdk-11 /usr/lib/jvm/java-11-openjdk \
    && adduser --shell /bin/bash --disabled-password policy \
    && mkdir -p ${POLICY_HOME}/etc/ssl \
    && chown -R policy:policy ${POLICY_HOME}
