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

DEFAULT_PORT=6969
DATA=/opt/robotworkspace/models/models-examples/src/main/resources/policies
NODETEMPLATES=/opt/robotworkspace/models/models-examples/src/main/resources/nodetemplates

POLICY_RUNTIME_ACM_IP=policy-clamp-runtime-acm:${DEFAULT_PORT}
POLICY_API_IP=policy-api:${DEFAULT_PORT}
POLICY_PAP_IP=policy-pap:${DEFAULT_PORT}
APEX_IP=policy-apex-pdp:${DEFAULT_PORT}
POLICY_PDPX_IP=policy-xacml-pdp:${DEFAULT_PORT}
POLICY_DROOLS_IP=policy-drools-pdp:9696

DMAAP_IP=message-router:3904
APEX_EVENTS_IP=policy-apex-pdp:23324
PROMETHEUS_IP=prometheus:9090

export ROBOT_VARIABLES=
ROBOT_VARIABLES="-v DATA:$DATA -v NODETEMPLATES:$NODETEMPLATES -v POLICY_API_IP:$POLICY_API_IP
-v POLICY_RUNTIME_ACM_IP:$POLICY_RUNTIME_ACM_IP -v POLICY_PAP_IP:$POLICY_PAP_IP -v APEX_IP:$APEX_IP
-v APEX_EVENTS_IP:$APEX_EVENTS_IP -v DMAAP_IP:$DMAAP_IP -v PROMETHEUS_IP:${PROMETHEUS_IP}
-v POLICY_PDPX_IP:$POLICY_PDPX_IP -v POLICY_DROOLS_IP:$POLICY_DROOLS_IP"

echo "Run Robot test"
echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ..."
python3 -m robot.run -d /tmp/ $ROBOT_VARIABLES $1
RESULT=$?
echo "RESULT: ${RESULT}"
