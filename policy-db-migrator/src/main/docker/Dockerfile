#-------------------------------------------------------------------------------
# Dockerfile
# ============LICENSE_START=======================================================
#  Copyright (C) 2021 Nordix Foundation.
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
FROM onap/policy-jdk-alpine:2.3.3-SNAPSHOT

LABEL maintainer="Policy Team"

ENV JAVA_HOME /usr/lib/jvm/java-11-openjdk
ENV POLICY_ETC /opt/app/policy/etc
ENV POLICY_PROFILE /opt/app/policy/etc/profile.d
ENV POLICY_BIN /opt/app/policy/bin

RUN apk update && \
    apk add --no-cache mariadb-client \
    net-tools netcat-openbsd sudo less vim && \
    mkdir -p $POLICY_PROFILE $POLICY_BIN && \
    chown -R policy:policy $POLICY_ETC $POLICY_BIN

COPY --chown=policy:policy ./env.sh $POLICY_PROFILE/
COPY --chown=policy:policy ./db-migrator $POLICY_BIN/
COPY --chown=policy:policy ./prepare_upgrade.sh $POLICY_BIN/
COPY --chown=policy:policy ./prepare_downgrade.sh $POLICY_BIN/
COPY --chown=policy:policy ./config/policyadmin/sql /home/policy/sql

WORKDIR $POLICY_BIN
USER policy:policy
