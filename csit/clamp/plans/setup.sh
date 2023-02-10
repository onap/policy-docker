#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2021-2023 Nordix Foundation.
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
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-runtime-acm grafana

sleep 10
unset http_proxy https_proxy

POLICY_RUNTIME_ACM_IP=$(get-instance-ip.sh policy-clamp-runtime-acm)
POLICY_RUNTIME_ACM_PORT=30258
MARIADB_IP=$(get-instance-ip.sh mariadb)
DMAAP_IP=$(get-instance-ip.sh simulator)

echo MARIADB IP IS "${MARIADB_IP}"
echo DMAAP_IP IS "${DMAAP_IP}"
echo POLICY RUNTIME ACM IP IS "${POLICY_RUNTIME_ACM_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${POLICY_RUNTIME_ACM_PORT}"

# TODO: This disables the participant during ACM refactoring, will be reenabled when ACM
# TODO: tests are re-enabled

# Bring up ACM participant containers
#docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-k8s-ppnt
#docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-http-ppnt
#docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-pf-ppnt
#docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d policy-clamp-ac-a1pms-ppnt

#sleep 10
unset http_proxy https_proxy

POLICY_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-pf-ppnt)
POLICY_PARTICIPANT_PORT=30218
POLICY_API_IP=$(get-instance-ip.sh policy-api)
POLICY_API_PORT=30440
K8S_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-k8s-ppnt)
K8S_PARTICIPANT_PORT=30295
HTTP_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-http-ppnt)
HTTP_PARTICIPANT_PORT=30290
A1PMS_PARTICIPANT_IP=$(get-instance-ip.sh policy-clamp-ac-a1pms-ppnt)
A1PMS_PARTICIPANT_PORT=30296

echo POLICY PARTICIPANT IP IS "${POLICY_PARTICIPANT_IP}"
echo API IP IS "${POLICY_API_IP}"
echo K8S PARTICIPANT IP IS "${K8S_PARTICIPANT_IP}"
echo HTTP PARTICIPANT IP IS "${HTTP_PARTICIPANT_IP}"
echo A1PMS PARTICIPANT IP IS "${A1PMS_PARTICIPANT_IP}"

# wait for the app to start up
#"${SCRIPTS}"/wait_for_rest.sh localhost "${POLICY_PARTICIPANT_PORT}"

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_RUNTIME_ACM_IP:${POLICY_RUNTIME_ACM_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_RUNTIME_ACM_PORT:${POLICY_RUNTIME_ACM_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PARTICIPANT_IP:${POLICY_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PARTICIPANT_PORT:${POLICY_PARTICIPANT_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v K8S_PARTICIPANT_IP:${K8S_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v K8S_PARTICIPANT_PORT:${K8S_PARTICIPANT_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v HTTP_PARTICIPANT_IP:${HTTP_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v HTTP_PARTICIPANT_PORT:${HTTP_PARTICIPANT_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v A1PMS_PARTICIPANT_IP:${A1PMS_PARTICIPANT_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v A1PMS_PARTICIPANT_PORT:${A1PMS_PARTICIPANT_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_IP:${POLICY_API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_PORT:${POLICY_API_PORT}"
