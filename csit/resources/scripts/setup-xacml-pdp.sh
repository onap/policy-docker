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

source "${SCRIPTS}"/node-templates.sh

source "${WORKSPACE}"/compose/start-compose.sh xacml-pdp

sleep 10
unset http_proxy https_proxy

export DMAAP_IP="localhost:${DMAAP_PORT}"
export SUITES="xacml-pdp-test.robot"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${XACML_PORT}"

ROBOT_VARIABLES="-v DATA:${DATA} -v POLICY_PDPX_IP:localhost:${XACML_PORT}
-v POLICY_API_IP:localhost:${API_PORT} -v POLICY_PAP_IP:localhost:${PAP_PORT}"
