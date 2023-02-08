#!/bin/bash
#
# ===========LICENSE_START====================================================
#  Copyright (C) 2023 Nordix Foundation. All rights reserved.
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
# Creates a topic, which happens as a side-effect of polling it.
#

if [ $# -ne 1 ]
then
    echo "arg(s): topic-name" >&2
    exit 1
fi

topic="${1}"

curl -s -k "http://${SIM_IP}:3904/events/${topic}/script/1?limit=1&timeout=0"
echo
