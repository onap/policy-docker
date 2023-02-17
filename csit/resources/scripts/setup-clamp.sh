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

source "${WORKSPACE}"/compose/start-compose.sh policy-clamp-runtime-acm

sleep 10
unset http_proxy https_proxy

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${ACM_PORT}"

export SUITES="policy-clamp-test.robot"

ROBOT_VARIABLES="-v POLICY_RUNTIME_ACM_IP:localhost:${ACM_PORT}
-v POLICY_API_IP:localhost:${POLICY_API_PORT}"
