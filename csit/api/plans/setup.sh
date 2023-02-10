#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright (C) 2019-2021 AT&T Intellectual Property. All rights reserved.
# Modifications Copyright 2021-2023 Nordix Foundation.
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

echo "Uninstall docker-py and reinstall docker."
python3 -m pip uninstall -y docker-py
python3 -m pip uninstall -y docker
python3 -m pip install -U docker

source "${SCRIPTS}"/get-versions.sh

sudo apt-get -y install libxml2-utils
bash "${SCRIPTS}"/get-models-examples.sh

DATA=${WORKSPACE}/models/models-examples/src/main/resources/policies

NODETEMPLATES=${WORKSPACE}/models/models-examples/src/main/resources/nodetemplates

# create a couple of variations of the policy definitions
sed -e 's!Measurement_vGMUX!ADifferentValue!' \
        ${DATA}/vCPE.policy.monitoring.input.tosca.json \
    >${DATA}/vCPE.policy.monitoring.input.tosca.v1_2.json

sed -e 's!"version": "1.0.0"!"version": "2.0.0"!' \
        -e 's!"policy-version": 1!"policy-version": 2!' \
        ${DATA}/vCPE.policy.monitoring.input.tosca.json \
    >${DATA}/vCPE.policy.monitoring.input.tosca.v2.json

echo "${POLICY_API_VERSION}"

cd "${SCRIPTS}"
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d api grafana

sleep 10
unset http_proxy https_proxy

POLICY_API_IP=$(get-instance-ip.sh policy-api)
POLICY_API_PORT=$(get-container-published-port.sh policy-api)
MARIADB_IP=$(get-instance-ip.sh mariadb)

echo API IP IS "${POLICY_API_IP}"
echo MARIADB IP IS "${MARIADB_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "$POLICY_API_PORT"

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_PORT:${POLICY_API_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA:${DATA}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v NODETEMPLATES:${NODETEMPLATES}"