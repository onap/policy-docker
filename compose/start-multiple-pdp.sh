#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2023 Nordix Foundation.
# =============================================================================
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
# ============LICENSE_END======================================================

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi
COMPOSE_FOLDER="${WORKSPACE}"/compose

if [ -z "$ROBOT_LOG_DIR" ]; then
  export ROBOT_LOG_DIR=/tmp/
fi

cd ${COMPOSE_FOLDER}

echo "Configuring docker compose..."
source export-ports.sh > /dev/null 2>&1
source get-versions.sh > /dev/null 2>&1

export REPLICAS=${1}
docker compose -f docker-compose.postgres.yml -f docker-compose.pdp.scale.yml up -d apexpdp nginx grafana

cd ${WORKSPACE}
