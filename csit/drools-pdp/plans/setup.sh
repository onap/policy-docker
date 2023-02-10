#!/bin/bash
# ============LICENSE_START=======================================================
# Copyright 2017-2021 AT&T Intellectual Property. All rights reserved.
# Modifications Copyright 2021-2023 Nordix Foundation.
# ================================================================================
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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

docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d drools

POLICY_DROOLS_IP=$(get-instance-ip.sh drools)
POLICY_DROOLS_PORT=$(get-container-published-port.sh drools)
MARIADB_IP=$(get-instance-ip.sh mariadb)

echo DROOLS IP IS "${POLICY_DROOLS_IP}"
echo MARIADB IP IS "${MARIADB_IP}"

# wait for the app to start up - looking for telemetry service on port 30216 forwarded from 9696
"${SCRIPTS}"/wait_for_rest.sh localhost 30216

# give enough time for the controllers to come up
sleep 15

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_DROOLS_IP:${POLICY_DROOLS_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_DROOLS_PORT:${POLICY_DROOLS_PORT}"
