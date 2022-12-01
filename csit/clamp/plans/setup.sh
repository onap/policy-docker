#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2021-2022 Nordix Foundation.
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
pip uninstall -y docker-py
pip uninstall -y docker
pip install -U docker==2.7.0

sudo apt-get -y install libxml2-utils

source "${SCRIPTS}"/get-versions.sh

# Bringup ACM runtime containers
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-runtime-acm

sleep 10
unset http_proxy https_proxy

POLICY_RUNTIME_ACM_IP=$(get-instance-ip.sh policy-clamp-runtime-acm)
MARIADB_IP=$(get-instance-ip.sh mariadb)
DMAAP_IP=$(get-instance-ip.sh simulator)

echo MARIADB IP IS "${MARIADB_IP}"
echo DMAAP_IP IS "${DMAAP_IP}"
echo POLICY RUNTIME ACM IP IS "${POLICY_RUNTIME_ACM_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_port.sh "${POLICY_RUNTIME_ACM_IP}" 6969

# Bringup ACM participant containers
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-k8s-ppnt
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-http-ppnt
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-pf-ppnt
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-a1pms-ppnt

sleep 10
unset http_proxy https_proxy

POLICY_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-pf-ppnt)
POLICY_API_IP=$(get-instance-ip.sh policy-api)
K8S_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-k8s-ppnt)
HTTP_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-http-ppnt)
A1PMS_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-a1pms-ppnt)

echo POLICY PARTICIPANT IP IS "${POLICY_PARTICIPANT_IP}"
echo API IP IS "${POLICY_API_IP}"
echo K8S PARTICIPANT IP IS "${K8S_PARTICIPANT_IP}"
echo HTTP PARTICIPANT IP IS "${HTTP_PARTICIPANT_IP}"
echo A1PMS PARTICIPANT IP IS "${A1PMS_PARTICIPANT_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_port.sh "${POLICY_PARTICIPANT_IP}" 6969

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_RUNTIME_ACM_IP:${POLICY_RUNTIME_ACM_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PARTICIPANT_IP:${POLICY_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v K8S_PARTICIPANT_IP:${K8S_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v HTTP_PARTICIPANT_IP:${HTTP_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v A1PMS_PARTICIPANT_IP:${A1PMS_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"

