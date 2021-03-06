#!/bin/bash
#
# ===========LICENSE_START====================================================
#  Copyright (C) 2020-2021 AT&T Intellectual Property. All rights reserved.
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

#
# Injects an ONSET event on the DCAE_CL_OUTPUT topic.
#

if [ $# -ne 1 ]
then
    echo "arg(s): json-message-file-name" >&2
    exit 1
fi

curl -k -H "Content-type: application/json" --data-binary @$1 \
    https://${SIM_IP}:3905/events/unauthenticated.DCAE_CL_OUTPUT
echo
