#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Ericsson. All rights reserved.
#  Modifications Copyright (c) 2019-2023 Nordix Foundation.
#  Modifications Copyright (C) 2020-2021 AT&T Intellectual Property.
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

# Remaking the csar file in case if the file got corrupted
DIST_TEMP_FOLDER=/tmp/distribution

zip -F "${TEST_PLAN_DIR}"/data/csar/sample_csar_with_apex_policy.csar \
    --out "${TEST_PLAN_DIR}"/data/csar/csar_temp.csar

# Remake temp directory
rm -rf "${DIST_TEMP_FOLDER}"
mkdir "${DIST_TEMP_FOLDER}"

source "${WORKSPACE}"/compose/start-compose.sh distribution

sleep 10
unset http_proxy https_proxy

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${DIST_PORT}"

export SUITES="distribution-test.robot"

ROBOT_VARIABLES="-v APEX_EVENTS_IP:localhost:${APEX_EVENTS_PORT}
-v DISTRIBUTION_IP:localhost:${DIST_PORT} -v TEMP_FOLDER:${DIST_TEMP_FOLDER}"
