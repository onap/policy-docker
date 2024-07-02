#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2023-2024 Nordix Foundation.
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

# always 'docker' if running docker compose
export TEST_ENV="docker"

# docker compose fails when not running CSIT
if [ -z "$ROBOT_LOG_DIR" ]; then
  export ROBOT_LOG_DIR=/tmp/
  export ROBOT_FILES=none
  export PROJECT=api
fi

COMPOSE_FOLDER="${WORKSPACE}"/compose

cd ${COMPOSE_FOLDER}

source export-ports.sh > /dev/null 2>&1
source get-versions.sh > /dev/null 2>&1

echo "Collecting logs from docker compose containers..."
rm -rf docker_compose.log

# this will collect logs by service instead of mixing all together
containers=$(docker compose ps --all --format '{{.Service}}')

IFS=$'\n' read -d '' -r -a item_list <<< "$containers"
for item in "${item_list[@]}"
do
    if [ -n "$item" ]; then
        echo "======== Logs from ${item} ========" >> docker_compose.log
        docker compose logs $item >> docker_compose.log
        echo "===================================" >> docker_compose.log
    fi
done

cat docker_compose.log

echo "Tearing down containers..."
docker compose down -v --remove-orphans

cd ${WORKSPACE}
