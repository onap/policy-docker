#-------------------------------------------------------------------------------
# Dockerfile
# ============LICENSE_START=======================================================
#  Copyright (C) 2021-2025 OpenInfra Foundation Europe. All rights reserved.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END=========================================================
#-------------------------------------------------------------------------------
FROM onap/policy-jre-alpine:5.0.1-SNAPSHOT

LABEL maintainer="Policy Team"
LABEL org.opencontainers.image.title="Policy db-migrator"
LABEL org.opencontainers.image.description="Policy db-migrator image based on Alpine"
LABEL org.opencontainers.image.url="https://github.com/onap/policy-docker"
LABEL org.opencontainers.image.vendor="ONAP Policy Team"
LABEL org.opencontainers.image.licenses="Apache-2.0"
LABEL org.opencontainers.image.created="${git.build.time}"
LABEL org.opencontainers.image.version="${git.build.version}"
LABEL org.opencontainers.image.revision="${git.commit.id.abbrev}"

ENV JAVA_HOME /usr/lib/jvm/java-17-openjdk
ENV POLICY_ETC /opt/app/policy/etc
ENV POLICY_PROFILE /opt/app/policy/etc/profile.d
ENV POLICY_BIN /opt/app/policy/bin

USER root
RUN apk update && \
    apk add --no-cache \
        postgresql-client \
        net-tools \
        netcat-openbsd \
        sudo \
        less \
        vim && \
    mkdir -p $POLICY_PROFILE $POLICY_BIN && \
    chown -R policy:policy $POLICY_ETC $POLICY_BIN

COPY --chown=policy:policy ./env.sh $POLICY_PROFILE/
COPY --chown=policy:policy ./db-migrator-pg $POLICY_BIN/
COPY --chown=policy:policy ./prepare_upgrade.sh $POLICY_BIN/
COPY --chown=policy:policy ./prepare_downgrade.sh $POLICY_BIN/
COPY --chown=policy:policy ./config /home

WORKDIR $POLICY_BIN
USER policy:policy
