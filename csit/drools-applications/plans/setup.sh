#!/bin/bash
#
# ===========LICENSE_START====================================================
#  Copyright (C) 2019-2021 AT&T Intellectual Property. All rights reserved.
#  Modifications Copyright 2021-2022 Nordix Foundation.
# ============================================================================
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
# ============LICENSE_END=====================================================
#

echo "Uninstall docker-py and reinstall docker."
python3 -m pip uninstall -y docker-py
python3 -m pip uninstall -y docker
python3 -m pip install -U docker

sudo apt-get -y install libxml2-utils

source "${SCRIPTS}"/get-versions.sh
bash "${SCRIPTS}"/get-models-examples.sh

docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up -d drools-apps

unset http_proxy https_proxy

DROOLS_IP=$(get-instance-ip.sh drools-apps)
DROOLS_PORT=$(get-container-published-port.sh drools-apps)
API_IP=$(get-instance-ip.sh policy-api)
API_PORT=$(get-container-published-port.sh policy-api)
PAP_IP=$(get-instance-ip.sh policy-pap)
PAP_PORT=$(get-container-published-port.sh policy-pap)
XACML_IP=$(get-instance-ip.sh policy-xacml-pdp)
XACML_PORT=$(get-container-published-port.sh policy-xacml-pdp)
SIM_IP=$(get-instance-ip.sh simulator)
export SIM_IP

echo DROOLS IP IS "${DROOLS_IP}"
echo API IP IS "${API_IP}"
echo PAP IP IS "${PAP_IP}"
echo XACML IP IS "${XACML_IP}"
echo SIMULATORS IP IS "${SIM_IP}"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost 30219

# give enough time for the controllers to come up
sleep 15

DATA=${WORKSPACE}/models/models-examples/src/main/resources/policies
DATA2=${TESTPLANDIR}/tests/data

ROBOT_VARIABLES=""
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SCR2:${SCRIPTS}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA:${DATA}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DATA2:${DATA2}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DROOLS_IP:${DROOLS_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v DROOLS_PORT:${DROOLS_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v API_IP:${API_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v API_PORT:${API_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v PAP_IP:${PAP_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v PAP_PORT:${PAP_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v XACML_IP:${XACML_IP}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v XACML_PORT:${XACML_PORT}"
ROBOT_VARIABLES="${ROBOT_VARIABLES} -v SIM_IP:${SIM_IP}"
