#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2020-2021 AT&T Intellectual Property. All rights reserved.
#  Modifications Copyright 2021-2023 Nordix Foundation.
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

sudo apt-get -y install libxml2-utils

source "${SCRIPTS}"/get-versions.sh
bash "${SCRIPTS}"/get-models-examples.sh

docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d xacml-pdp

unset http_proxy https_proxy

POLICY_API_IP=$(get-instance-ip.sh policy-api)
POLICY_API_PORT=$(get-container-published-port.sh policy-api)
MARIADB_IP=$(get-instance-ip.sh mariadb)
POLICY_PDPX_IP=$(get-instance-ip.sh policy-xacml-pdp)
POLICY_PDPX_PORT=$(get-container-published-port.sh policy-xacml-pdp)
SIM_IP=$(get-instance-ip.sh simulator)
POLICY_PAP_IP=$(get-instance-ip.sh policy-pap)
POLICY_PAP_PORT=$(get-container-published-port.sh policy-pap)

export SIM_IP

echo XACML-PDP IP IS "${POLICY_PDPX_IP}"
echo API IP IS "${POLICY_API_IP}"
echo PAP IP IS "${POLICY_PAP_IP}"
echo MARIADB IP IS "${MARIADB_IP}"
echo SIM_IP IS "${SIM_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${POLICY_PDPX_PORT}"

DATA2=${WORKSPACE}/models/models-examples/src/main/resources/policies

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SCR_DMAAP:${SCRIPTS}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA2:${DATA2}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PDPX_IP:${POLICY_PDPX_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PDPX_PORT:${POLICY_PDPX_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_PORT:${POLICY_API_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PAP_IP:${POLICY_PAP_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PAP_PORT:${POLICY_PAP_PORT}"
