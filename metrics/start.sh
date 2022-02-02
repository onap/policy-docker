#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2022 Nordix Foundation.
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

source "$(pwd)"/get_images_versions.sh

if [ -z "${WORKSPACE}" ]; then
    export WORKSPACE=$(git rev-parse --show-toplevel)
fi

export PROJECT="${1}"

if [ -z "${PROJECT}" ]; then
    echo "Starting all components..."
    docker-compose -f compose-grafana.yml up -d
else
    echo "Starting ${PROJECT} application..."
    docker-compose -f compose-grafana.yml up -d "${PROJECT}" grafana
fi

prometheus=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' prometheus)
grafana=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' grafana)

echo "Prometheus server: http://${prometheus}:9090"
echo "Grafana server: http://${grafana}:3000"
