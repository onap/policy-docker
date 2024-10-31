#!/bin/bash -x
#
# Copyright 2024 Nordix Foundation.
#
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

function clone_models() {
    # download models examples
    git clone -b "${GERRIT_BRANCH}" --single-branch https://github.com/onap/policy-models.git "${WORKSPACE}"/csit/resources/tests/models

    # create a couple of variations of the policy definitions
    sed -e 's!Measurement_vGMUX!ADifferentValue!' \
        tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.json \
        >tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.v1_2.json

    sed -e 's!"version": "1.0.0"!"version": "2.0.0"!' \
        -e 's!"policy-version": 1!"policy-version": 2!' \
        tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.json \
        >tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.v2.json
}

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' "${WORKSPACE}"/.gitreview)
export ROBOT_DOCKER_IMAGE="policy-csit-robot"

echo "Build docker image for robot framework"
cd ${WORKSPACE}/csit/resources || exit

docker image rm -f ${ROBOT_DOCKER_IMAGE}

# get models
clone_models

echo "Build robot framework docker image"
docker build . --file Dockerfile  --tag "onap/${ROBOT_DOCKER_IMAGE}" --quiet
docker save -o policy-csit-robot.tar ${ROBOT_DOCKER_IMAGE}:latest

rm -rf ${WORKSPACE}/csit/resources/policy-csit-robot.tar
rm -rf ${WORKSPACE}/csit/resources/tests/models/
