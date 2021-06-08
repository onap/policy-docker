#!/bin/bash
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
source ${SCRIPTS}/get-branch-mariadb.sh

echo "Uninstall docker-py and reinstall docker."
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

sudo apt-get -y install libxml2-utils

source ${SCRIPTS}/clamp/plans/detmVers.sh

docker-compose -f ${SCRIPTS}/clamp/docker-compose-controlloop.yml up -d policy-controlloop-runtime

sleep 10
unset http_proxy https_proxy

POLICY_CONTROLLOOP_RUNTIME_IP=`get-instance-ip.sh policy-controlloop-runtime`
POLICY_PARTICIPANT_IP=`get-instance-ip.sh policy-participant`
DCAE_PARTICIPANT_IP=`get-instance-ip.sh dcae-participant`
MARIADB_IP=`get-instance-ip.sh mariadb`
DMAAP_IP=`get-instance-ip.sh simulator`
POLICY_API_IP=`get-instance-ip.sh policy-api`

echo MARIADB IP IS ${MARIADB_IP}
echo DMAAP_IP IS ${DMAAP_IP}
echo API IP IS ${POLICY_API_IP}
echo POLICY CONTROLLOOP RUNTIME IP IS ${POLICY_CONTROLLOOP_RUNTIME_IP}
echo POLICY PARTICIPANT IP IS ${POLICY_PARTICIPANT_IP}
echo DCAE PARTICIPANT IP IS ${DCAE_PARTICIPANT_IP}

# wait for the app to start up
${SCRIPTS}/wait_for_port.sh ${POLICY_CONTROLLOOP_RUNTIME_IP} 6970

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_CONTROLLOOP_RUNTIME_IP:${POLICY_CONTROLLOOP_RUNTIME_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PARTICIPANT_IP:${POLICY_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DCAE_PARTICIPANT_IP:${DCAE_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"
