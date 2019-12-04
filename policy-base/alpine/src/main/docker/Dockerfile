#   ============LICENSE_START=======================================================
#    Copyright (C) 2019 Tieto. All rights reserved.
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
# $JAVA_HOME is set to /usr/lib/jvm/java-1.8-openjdk
# more details at https://hub.docker.com/_/openjdk

FROM alpine:3.7

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
    openjdk8 \
    procps \
    unzip \
    wget \
    zip
