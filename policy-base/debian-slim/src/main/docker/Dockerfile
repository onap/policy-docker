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

# change "jre" to "jdk" for an image using the full JDK

FROM openjdk:11-jre-slim

LABEL maintainer="Policy Team"

RUN apt-get -y update \
    && apt-get -y install \
        curl \
        less \
        ssh \
        unzip \
        wget \
        zip
