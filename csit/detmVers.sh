# ============LICENSE_START====================================================
#  Copyright (C) 2020-2021 AT&T Intellectual Property. All rights reserved.
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

. "${SCRIPTS}"/get-branch-mariadb.sh

echo POLICY_MARIADB_VER="${POLICY_MARIADB_VER}"

getVersion() {
    REPO=$1
    curl -qL --silent \
      https://github.com/onap/policy-"$REPO"/raw/"${GERRIT_BRANCH}"/pom.xml |
    xmllint --xpath \
      '/*[local-name()="project"]/*[local-name()="version"]/text()' -
}

POLICY_MODELS_VERSION=$(getVersion models)
POLICY_MODELS_VERSION=$(echo "$POLICY_MODELS_VERSION" | cut -c 1-3)
export POLICY_MODELS_VERSION=${POLICY_MODELS_VERSION}-SNAPSHOT-latest
echo POLICY_MODELS_VERSION="${POLICY_MODELS_VERSION}"

POLICY_API_VERSION=$(getVersion api)
POLICY_API_VERSION=$(echo "$POLICY_API_VERSION" | cut -c 1-3)
export POLICY_API_VERSION=${POLICY_API_VERSION}-SNAPSHOT-latest
echo POLICY_API_VERSION="${POLICY_API_VERSION}"

POLICY_PAP_VERSION=$(getVersion pap)
POLICY_PAP_VERSION=$(echo "$POLICY_PAP_VERSION" | cut -c 1-3)
export POLICY_PAP_VERSION=${POLICY_PAP_VERSION}-SNAPSHOT-latest
echo POLICY_PAP_VERSION="${POLICY_PAP_VERSION}"

POLICY_XACML_PDP_VERSION=$(getVersion xacml-pdp)
POLICY_XACML_PDP_VERSION=$(echo "$POLICY_XACML_PDP_VERSION" | cut -c 1-3)
export POLICY_XACML_PDP_VERSION=${POLICY_XACML_PDP_VERSION}-SNAPSHOT-latest
echo POLICY_XACML_PDP_VERSION="${POLICY_XACML_PDP_VERSION}"

POLICY_DROOLS_VERSION=$(getVersion drools-pdp)
POLICY_DROOLS_VERSION=$(echo "$POLICY_DROOLS_VERSION" | cut -c 1-3)
export POLICY_DROOLS_VERSION=${POLICY_DROOLS_VERSION}-SNAPSHOT-latest
echo POLICY_DROOLS_VERSION="${POLICY_DROOLS_VERSION}"

POLICY_DROOLS_APPS_VERSION=$(getVersion drools-applications)
POLICY_DROOLS_APPS_VERSION=$(echo "$POLICY_DROOLS_APPS_VERSION" | cut -c 1-3)
export POLICY_DROOLS_APPS_VERSION=${POLICY_DROOLS_APPS_VERSION}-SNAPSHOT-latest
echo POLICY_DROOLS_APPS_VERSION="${POLICY_DROOLS_APPS_VERSION}"

POLICY_APEX_PDP_VERSION=$(getVersion apex-pdp)
POLICY_APEX_PDP_VERSION=$(echo "$POLICY_APEX_PDP_VERSION" | cut -c 1-3)
export POLICY_APEX_PDP_VERSION=${POLICY_APEX_PDP_VERSION}-SNAPSHOT-latest
echo POLICY_APEX_PDP_VERSION="${POLICY_APEX_PDP_VERSION}"

POLICY_DISTRIBUTION_VERSION=$(getVersion distribution)
POLICY_DISTRIBUTION_VERSION=$(echo "$POLICY_DISTRIBUTION_VERSION" | cut -c 1-3)
export POLICY_DISTRIBUTION_VERSION=${POLICY_DISTRIBUTION_VERSION}-SNAPSHOT-latest
echo POLICY_DISTRIBUTION_VERSION="${POLICY_DISTRIBUTION_VERSION}"
