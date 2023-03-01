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

export PROJECT="apex-pdp"
source "${SCRIPTS}"/node-templates.sh

source "${WORKSPACE}"/compose/start-multiple-pdp.sh 10

sleep 10
unset http_proxy https_proxy

# wait for the app to start up
bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
bash "${SCRIPTS}"/wait_for_rest.sh localhost ${APEX_PORT}

sleep 20

healthy=false

while [ $healthy = false ]
do
    msg=`curl -s -k --user 'policyadmin:zb!XztG34' http://localhost:${APEX_PORT}/policy/apex-pdp/v1/healthcheck`
    echo "${msg}" | grep -q true
    if [ "${?}" -eq 0 ]
    then
        healthy=true
        break
    fi
    sleep 10s
done

export DMAAP_IP="localhost:${DMAAP_PORT}"
export SUITES="apex-slas-10.robot"

ROBOT_VARIABLES="-v POLICY_PAP_IP:localhost:${PAP_PORT} -v POLICY_API_IP:localhost:${API_PORT}
-v PROMETHEUS_IP:localhost:${PROMETHEUS_PORT} -v DATA:${DATA} -v NODETEMPLATES:${NODETEMPLATES}
-v APEX_IP:localhost:${APEX_PORT} -v DMAAP_IP:${DMAAP_IP}
-v APEX_EVENTS_IP:localhost:${APEX_PORT}"
