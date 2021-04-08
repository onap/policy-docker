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

source ${SCRIPTS}/get-branch-mariadb.sh

echo POLICY_MARIADB_VER=${POLICY_MARIADB_VER}

POLICY_MODELS_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-models/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_MODELS_VERSION=${POLICY_MODELS_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_MODELS_VERSION=${POLICY_MODELS_VERSION}

POLICY_API_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-api/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_API_VERSION=${POLICY_API_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_API_VERSION=${POLICY_API_VERSION}

POLICY_PAP_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-pap/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_PAP_VERSION=${POLICY_PAP_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_PAP_VERSION=${POLICY_PAP_VERSION}

POLICY_XACML_PDP_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-xacml-pdp/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_XACML_PDP_VERSION=${POLICY_XACML_PDP_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_XACML_PDP_VERSION=${POLICY_XACML_PDP_VERSION}

POLICY_DROOLS_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-drools-pdp/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_DROOLS_VERSION=${POLICY_DROOLS_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_DROOLS_VERSION=${POLICY_DROOLS_VERSION}

POLICY_DROOLS_APPS_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-drools-applications/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_DROOLS_APPS_VERSION=${POLICY_DROOLS_APPS_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_DROOLS_APPS_VERSION=${POLICY_DROOLS_APPS_VERSION}

POLICY_APEX_PDP_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-apex-pdp/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_APEX_PDP_VERSION=${POLICY_APEX_PDP_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_APEX_PDP_VERSION=${POLICY_APEX_PDP_VERSION}

POLICY_DISTRIBUTION_VERSION=$(
    curl -qL --silent \
      https://github.com/onap/policy-distribution/raw/${GERRIT_BRANCH}/pom.xml |
    xmllint --xpath '/*[local-name()="project"]/*[local-name()="version"]/text()' -)
export POLICY_DISTRIBUTION_VERSION=${POLICY_DISTRIBUTION_VERSION:0:3}-SNAPSHOT-latest
echo POLICY_DISTRIBUTION_VERSION=${POLICY_DISTRIBUTION_VERSION}
