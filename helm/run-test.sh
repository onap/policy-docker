#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2023 Nordix Foundation.
# =============================================================================
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
# ============LICENSE_END======================================================


ROBOT_FILE=$1
echo "Invoking the robot tests from: $1"

export DATA=/opt/robotworkspace/models/models-examples/src/main/resources/policies
export NODETEMPLATES=/opt/robotworkspace/models/models-examples/src/main/resources/nodetemplates
export POLICY_RUNTIME_ACM_IP=policy-clamp-runtime-acm
export POLICY_API_IP=policy-api
export POLICY_PAP_IP=policy-pap
export APEX_IP=policy-apex-pdp
export DMAAP_IP=message-router
export SIM_IP=message-router

export ROBOT_VARIABLES=
ROBOT_VARIABLES="-v DATA:$DATA -v NODETEMPLATES:$NODETEMPLATES -v POLICY_RUNTIME_ACM_IP:$POLICY_RUNTIME_ACM_IP -v POLICY_API_IP:$POLICY_API_IP
-v POLICY_PAP_IP:$POLICY_PAP_IP -v APEX_IP:$APEX_IP -v DMAAP_IP:$DMAAP_IP -v SIM_IP:$SIM_IP"

echo "Run Robot test"
echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ..."
python3 -m robot.run -d /tmp/ $ROBOT_VARIABLES $1
RESULT=$?
echo "RESULT: ${RESULT}"
