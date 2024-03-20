#!/bin/bash
#
# Copyright 2024 Nordix Foundation.

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Script to run the ACM regression test suite in cucumber.
# Deploys ACM-R and participants in two different release versions for testing backward compatibility.

if [ $# -eq 0 ]
then
    echo "No release versions provided. Testing ACM-R and participants with the default version"
    echo "Usage: $0 <acm_release> <compatibility_test_release>"
    ACM_RELEASE=$(awk -F= '$1 == "defaultbranch" { print $2 }' \
                            "${WORKSPACE}"/.gitreview)
    PPNT_RELEASE=$ACM_RELEASE
fi

if [ $1 ]; then
    ACM_RELEASE=$1
fi

if [ $2 ]; then
    PPNT_RELEASE=$2
fi

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi


export SCRIPTS="${WORKSPACE}/csit/resources/scripts"

COMPOSE_FOLDER="${WORKSPACE}"/compose
REGRESSION_FOLDER="${WORKSPACE}"/policy-regression-tests/policy-clamp-regression/
export PROJECT='clamp'

# Sign in to nexus3 docker repo
docker login -u docker -p docker nexus3.onap.org:10001

cd ${COMPOSE_FOLDER}

echo "Configuring docker compose..."

source export-ports.sh > /dev/null 2>&1
source get-versions-regression.sh $ACM_RELEASE $PPNT_RELEASE > /dev/null 2>&1

docker-compose -f docker-compose.yml up -d "policy-clamp-runtime-acm"

# wait for the app to start up
"${SCRIPTS}"/wait_for_rest.sh localhost "${ACM_PORT}"

cd ${REGRESSION_FOLDER}

# Invoke the regression test cases
mvn clean test -Dtests.skip=false