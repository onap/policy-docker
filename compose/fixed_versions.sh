#! /bin/bash

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

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' \
                    "${WORKSPACE}"/.gitreview)

echo GERRIT_BRANCH="${GERRIT_BRANCH}"

export POLICY_MARIADB_VER=10.10.2
echo POLICY_MARIADB_VER=${POLICY_MARIADB_VER}

export POLICY_POSTGRES_VER=11.1
echo POLICY_POSTGRES_VER=${POLICY_POSTGRES_VER}

export POLICY_DOCKER_VERSION="3.0.1-SNAPSHOT"

export POLICY_MODELS_VERSION="3.0.1-SNAPSHOT"

export POLICY_API_VERSION="3.0.1-SNAPSHOT"

export POLICY_PAP_VERSION="3.0.1-SNAPSHOT"

export POLICY_APEX_PDP_VERSION="3.0.1-SNAPSHOT"

export POLICY_DROOLS_PDP_VERSION="2.0.0-SNAPSHOT"

export POLICY_XACML_PDP_VERSION="3.0.0-SNAPSHOT"

export POLICY_DISTRIBUTION_VERSION="3.0.1-SNAPSHOT"

export POLICY_CLAMP_VERSION="7.0.1-SNAPSHOT"

export POLICY_GUI_VERSION="3.0.0-SNAPSHOT"

export POLICY_DROOLS_APPS_VERSION="2.0.0-SNAPSHOT"
