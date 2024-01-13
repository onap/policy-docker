#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2018 Ericsson. All rights reserved.
#
#  Modifications Copyright (c) 2019-2024 Nordix Foundation.
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

source "${SCRIPTS}"/setup-pap.sh

# wait for the app to start up
bash "${SCRIPTS}"/wait_for_rest.sh localhost ${APEX_PORT}

export KAFKA_IP="kafka:${KAFKA_PORT}"
export SUITES="apex-pdp-test.robot
apex-slas.robot"

ROBOT_VARIABLES="${ROBOT_VARIABLES} -v APEX_IP:localhost:${APEX_PORT} -v KAFKA_IP:${KAFKA_IP}
-v APEX_EVENTS_IP:localhost:${APEX_EVENTS_PORT}"
