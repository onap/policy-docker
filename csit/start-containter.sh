# ============LICENSE_START====================================================
# Copyright (C) 2022 Nordix Foundation.
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


if [ "$#" -ne 1 ]
then
  echo "Usage: $0 <container-name>"
  exit 1
fi

export PROJECT=$1

if $(docker images | grep -q "onap\/policy-api")
then
    export CONTAINER_LOCATION=$(
        docker images |
        grep onap/policy-api |
        head -1 |
        sed 's/onap\/policy-api.*$//'
    )
else
    export CONTAINER_LOCATION="nexus3.onap.org:10001/"
fi

SCRIPTS=$(git rev-parse --show-toplevel)
export SCRIPTS="${SCRIPTS}"/csit

source "${SCRIPTS}"/get-versions.sh

docker-compose -f "${SCRIPTS}"/docker-compose-all.yml up $*

echo "Clamp GUI: https://localhost:2445/clamp"
