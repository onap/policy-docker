#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Ericsson. All rights reserved.
#
#  Modifications Copyright (c) 2019-2023 Nordix Foundation.
#  Modifications Copyright (C) 2020-2021 AT&T Intellectual Property.
#  Modifications Copyright (C) 2021 Bell Canada. All rights reserved.
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

docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d apex-pdp grafana

unset http_proxy https_proxy

POLICY_API_IP=$(get-instance-ip.sh policy-api)
POLICY_API_PORT=30440
POLICY_PAP_IP=$(get-instance-ip.sh policy-pap)
POLICY_PAP_PORT=30442
MARIADB_IP=$(get-instance-ip.sh mariadb)
APEX_IP=$(get-instance-ip.sh policy-apex-pdp)
APEX_PORT=30237
SIM_IP=$(get-instance-ip.sh simulator)
export SIM_IP

echo PAP IP IS "${POLICY_PAP_IP}"
echo MARIADB IP IS "${MARIADB_IP}"
echo API IP IS "${POLICY_API_IP}"
echo APEX IP IS "${APEX_IP}"
echo DMAAP_IP IS "${SIM_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${APEX_PORT}"

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SCRIPTS:${SCRIPTS}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v APEX_IP:${APEX_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v APEX_PORT:${APEX_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_PORT:${POLICY_API_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PAP_IP:${POLICY_PAP_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PAP_PORT:${POLICY_PAP_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DMAAP_IP:${SIM_IP}"
