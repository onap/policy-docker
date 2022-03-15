# ============LICENSE_START====================================================
#  Copyright (C) 2020-2021 AT&T Intellectual Property. All rights reserved.
#  Modification Copyright 2021-2022 Nordix Foundation.
#  Modifications Copyright (C) 2021 Bell Canada. All rights reserved.
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

export SCRIPTS=$(pwd)
echo $SCRIPTS

source "${SCRIPTS}"/get-branch.sh

export POLICY_MARIADB_VER=10.5.8
echo POLICY_MARIADB_VER=${POLICY_MARIADB_VER}

function getVersion
{
    REPO=$1
    curl -qL --silent \
      https://github.com/onap/policy-"$REPO"/raw/"${GERRIT_BRANCH}"/pom.xml |
    xmllint --xpath \
      '/*[local-name()="project"]/*[local-name()="version"]/text()' - |
    awk -F \. '{print $1"."$2"-SNAPSHOT-latest"}'
}

export POLICY_MODELS_VERSION=$(getVersion models)
echo POLICY_MODELS_VERSION="${POLICY_MODELS_VERSION}"

export POLICY_API_VERSION=$(getVersion api)
echo POLICY_API_VERSION="${POLICY_API_VERSION}"

export POLICY_PAP_VERSION=$(getVersion pap)
echo POLICY_PAP_VERSION="${POLICY_PAP_VERSION}"

export POLICY_XACML_PDP_VERSION=$(getVersion xacml-pdp)
echo POLICY_XACML_PDP_VERSION="${POLICY_XACML_PDP_VERSION}"

export POLICY_DROOLS_VERSION=$(getVersion drools-pdp)
echo POLICY_DROOLS_VERSION="${POLICY_DROOLS_VERSION}"

export POLICY_DROOLS_APPS_VERSION=$(getVersion drools-applications)
echo POLICY_DROOLS_APPS_VERSION="${POLICY_DROOLS_APPS_VERSION}"

export POLICY_APEX_PDP_VERSION=$(getVersion apex-pdp)
echo POLICY_APEX_PDP_VERSION="${POLICY_APEX_PDP_VERSION}"

export POLICY_DISTRIBUTION_VERSION=$(getVersion distribution)
echo POLICY_DISTRIBUTION_VERSION="${POLICY_DISTRIBUTION_VERSION}"

export POLICY_CLAMP_VERSION=$(getVersion clamp)
echo POLICY_CLAMP_VERSION="${POLICY_CLAMP_VERSION}"

export POLICY_DOCKER_VERSION=$(getVersion docker)
echo POLICY_DOCKER_VERSION="${POLICY_DOCKER_VERSION}"

export POLICY_GUI_VERSION=$(getVersion gui)
echo POLICY_GUI_VERSION="${POLICY_GUI_VERSION}"
