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

# Usage: --start to run the docker compose with apex-pdp replicas
#        --stop to stop the docker compose containers
#        --replicas number of replicas (defaults to 2)

# Initialize variables
START=false
REPLICAS=2

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --start)
            START=true
            shift
            ;;
        --stop)
            START=false
            shift
            ;;
        --replicas=*)
            REPLICAS="${1#*=}"
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

COMPOSE_FOLDER="${WORKSPACE}"/compose

cd ${COMPOSE_FOLDER}

source export-ports.sh > /dev/null 2>&1
source get-versions.sh > /dev/null 2>&1

export REPLICAS

export database=postgres

if [ "$START" = true ]; then
    echo "Configuring docker compose for apex-pdp scaled with ${REPLICAS} replicas..."
    docker compose -f compose.pdp.scale.yml up -d apexpdp nginx grafana postgres
else
    echo "Collecting logs..."
    containers=$(docker compose -f compose.pdp.scale.yml ps --all --format '{{.Service}}')

    IFS=$'\n' read -d '' -r -a item_list <<< "$containers"
    for item in "${item_list[@]}"
    do
        if [ -n "$item" ]; then
            docker compose -f compose.pdp.scale.yml logs $item >> $item.log
        fi
    done

    echo "Stopping compose containers..."
    docker compose -f compose.pdp.scale.yml down -v --remove-orphans
fi

cd ${WORKSPACE}
