#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2019-2022 Nordix Foundation.
#  Modifications Copyright (C) 2019-2021 AT&T Intellectual Property.
#  Modifications Copyright (C) 2022-2023 Nordix Foundation.
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

echo "${POLICY_PAP_VERSION}"

cd "${SCRIPTS}"
docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d pap apex-pdp grafana

sleep 10
unset http_proxy https_proxy

POLICY_PAP_PORT=30442
POLICY_API_PORT=30440

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${POLICY_PAP_PORT}"

DATA=${WORKSPACE}/models/models-examples/src/main/resources/policies

NODETEMPLATES=${WORKSPACE}/models/models-examples/src/main/resources/nodetemplates

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_PAP_PORT:${POLICY_PAP_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_API_PORT:${POLICY_API_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA:${DATA}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v NODETEMPLATES:${NODETEMPLATES}"
