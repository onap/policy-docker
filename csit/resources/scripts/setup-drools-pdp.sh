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

source "${WORKSPACE}"/compose/start-compose.sh drools-pdp

sleep 10
unset http_proxy https_proxy

export SUITES="drools-pdp-test.robot"

# wait for the app to start up - looking for telemetry service on port ${DROOLS_PORT} forwarded from 9696
"${SCRIPTS}"/wait_for_rest.sh localhost ${DROOLS_TELEMETRY_PORT}

# give enough time for the controllers to come up
sleep 15

ROBOT_VARIABLES="${ROBOT_VARIABLES} -v POLICY_DROOLS_IP:localhost:${DROOLS_TELEMETRY_PORT}"
