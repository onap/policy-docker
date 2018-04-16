# Copyright 2018 AT&T Intellectual Property. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
FROM ubuntu:14.04

ARG HTTP_PROXY=${HTTP_PROXY}
ARG HTTPS_PROXY=${HTTPS_PROXY}

ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY

RUN \
        apt-get clean && \
        apt-get update && \
        apt-get install -y zip unzip curl wget ssh telnet maven && \
        apt-get install -y software-properties-common && \
        apt-get install -y jq httpie && \
        apt-get install -y python-pip && \
        add-apt-repository ppa:openjdk-r/ppa && \
        apt-get clean && \
        apt-get update && \
        apt-get install -y openjdk-8-jdk

RUN useradd --create-home --shell /bin/bash policy

# note that in following command sequence, wget exit status is 1 even on success,
# so can't use && for conditional execution of next command
RUN \
    cd /tmp && \
    wget https://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.14.2-01-bundle.tar.gz ; \
    mkdir /opt/nexus && cd /opt/nexus && \
    tar xfz /tmp/nexus-2.14.2-01-bundle.tar.gz && \
    useradd --create-home --shell /bin/bash nexus && \
    chown -R nexus *

# make the sonatype-work directory persistent
VOLUME /opt/nexus/sonatype-work

USER nexus
CMD bash -c "/opt/nexus/nexus-2.14.2-01/bin/nexus start && sleep 1000d"

