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

echo "Shut down started!"
if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi
COMPOSE_FOLDER="${WORKSPACE}"/compose

source "${COMPOSE_FOLDER}"/export-ports.sh > /dev/null 2>&1
source "${COMPOSE_FOLDER}"/get-versions.sh > /dev/null 2>&1

echo "Collecting logs from docker compose containers..."
docker-compose -f "${COMPOSE_FOLDER}"/docker-compose.yml logs > docker_compose.log

echo "Tearing down containers..."
docker-compose -f "${COMPOSE_FOLDER}"/docker-compose.yml down -v
