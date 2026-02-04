#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 © Samsung Electronics Co., Ltd.
# Modification Copyright 2021 © AT&T Intellectual Property.
# Modification Copyright 2021-2025 OpenInfra Foundation Europe.
# Modifications Copyright 2024-2025 Deutsche Telekom
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
#
# SPDX-License-Identifier: Apache-2.0

SKIP_BUILDING_ROBOT_IMG=false
DO_NOT_TEARDOWN=false

# even with forced finish, clean up docker containers
function on_exit(){
    rm -rf "${CSAR_DIR}"/csar_temp.csar

    if [ "${DO_NOT_TEARDOWN}" = false ]; then
        source "${DOCKER_COMPOSE_DIR}"/stop-compose.sh "${PROJECT}"
        mv "${DOCKER_COMPOSE_DIR}"/*.log "${ROBOT_LOG_DIR}"
    fi

    exit $RC
}

function docker_stats(){
    # General memory details
    if [ "$(uname -s)" == "Darwin" ]
    then
        sh -c "top -l1 | head -10"
        echo
    else
        sh -c "top -bn1 | head -3"
        echo

        sh -c "free -h"
        echo
    fi

    # Memory details per Docker
    docker ps --format "table {{ .Image }}\t{{ .Names }}\t{{ .Status }}"
    echo

    docker stats --no-stream
    echo
}

function apex_healthcheck() {
    sleep 20

    healthy=false

    while [ $healthy = false ]
    do
        msg=$(curl -s -k --user 'policyadmin:zb!XztG34' http://localhost:"${APEX_PORT}"/policy/apex-pdp/v1/healthcheck)
        echo "${msg}" | grep -q true
        if [ "${?}" -eq 0 ]
        then
            healthy=true
            break
        fi
        sleep 10s
    done

    if  [ $healthy = false ]; then
        exit 2
    fi
}

function check_rest_endpoint() {
    bash "${SCRIPTS}"/wait_for_rest.sh localhost "${1}"
    rc=$?
    if [ $rc -ne 0 ]; then
        on_exit
    fi
}

function setup_clamp() {
    export ROBOT_FILES="clamp-health-check.robot clamp-db-restore.robot clamp-single-element-test.robot clamp-timeout-test.robot
    clamp-migrate-rollback.robot clamp-trace-test.robot clamp-slas.robot"
    export TEST_ENV="docker"
    export PROJECT="clamp"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-clamp-runtime-acm --grafana
    echo "Waiting 2 minutes for the replicas to be started..."
    sleep 120
    check_rest_endpoint "${ACM_PORT}"
}

function setup_api() {
    export ROBOT_FILES="api-test.robot api-slas.robot"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-api --grafana
    echo "Waiting 1 minute for policy-api to start..."
    sleep 60
    check_rest_endpoint "${API_PORT}"
}

function setup_pap() {
    export ROBOT_FILES="pap-test.robot pap-slas.robot"
    export PROJECT="pap"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-apex-pdp --grafana
    echo "Waiting 1 minute for policy-pap to start..."
    sleep 60
    check_rest_endpoint "${PAP_PORT}"
    check_rest_endpoint "${APEX_PORT}"
    apex_healthcheck
}

function setup_apex() {
    export ROBOT_FILES="apex-pdp-test.robot apex-slas.robot"
    export PROJECT="apex-pdp"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-apex-pdp --grafana
    echo "Waiting 1 minute for apex-pdp to start..."
    sleep 60
    check_rest_endpoint "${PAP_PORT}"
    check_rest_endpoint "${APEX_PORT}"
    apex_healthcheck
}



function setup_drools_apps() {
    export ROBOT_FILES="drools-applications-test.robot drools-applications-slas.robot"
    export PROJECT="drools-applications"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-drools-apps --grafana
    echo "Waiting 1 minute for drools-pdp and drools-applications to start..."
    sleep 80
    check_rest_endpoint "${PAP_PORT}"
    check_rest_endpoint "${XACML_PORT}"
    check_rest_endpoint "${DROOLS_APPS_PORT}"
    check_rest_endpoint "${DROOLS_APPS_TELEMETRY_PORT}"
}

function setup_xacml_pdp() {
    export ROBOT_FILES="xacml-pdp-test.robot xacml-pdp-slas.robot"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-xacml-pdp --grafana
    echo "Waiting 1 minute for xacml-pdp to start..."
    sleep 60
    check_rest_endpoint "${XACML_PORT}"
}

function setup_opa_pdp() {
    export ROBOT_FILES="opa-pdp-test.robot opa-pdp-slas.robot"
    export PROJECT="opa-pdp"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-opa-pdp --grafana
    echo "Waiting 3 minutes for OPA-PDP to start..."
    sleep 180
    check_rest_endpoint "${PAP_PORT}"
    check_rest_endpoint "${OPA_PDP_PORT}"
}

function setup_drools_pdp() {
    export ROBOT_FILES="drools-pdp-test.robot"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-drools-pdp --grafana
    echo "Waiting 1 minute for drools-pdp to start..."
    sleep 60
    check_rest_endpoint "${DROOLS_TELEMETRY_PORT}"
}

function setup_distribution() {
    # Prepare CSAR file for distribution test
    zip -F "${CSAR_DIR}"/sample_csar_with_apex_policy.csar --out "${CSAR_DIR}"/csar_temp.csar -q

    # Create clean directory for CSAR files (mounted into policy-distribution container)
    rm -rf /tmp/distribution
    mkdir /tmp/distribution

    export ROBOT_FILES="distribution-test.robot"
    source "${DOCKER_COMPOSE_DIR}"/start-compose.sh policy-distribution --grafana
    echo "Waiting 1 minute for distribution to start..."
    sleep 60
    check_rest_endpoint "${DIST_PORT}"
    check_rest_endpoint "${APEX_PORT}"
    apex_healthcheck
}

function build_robot_image() {
    bash "${SCRIPTS}"/build-csit-docker-image.sh
    cd "${WORKSPACE}" || exit
}

function run_robot() {
    docker compose -f "${DOCKER_COMPOSE_DIR}"/compose.yaml up csit-tests
    export RC=$?
}

function set_project_config() {
    echo "Setting project configuration for: $PROJECT"
    case $PROJECT in

    clamp | policy-clamp)
        export ACM_REPLICAS=2
        setup_clamp
        ;;

    clamp-simple | policy-simple)
        export ACM_REPLICAS=1
        setup_clamp
        ;;

    api | policy-api)
        setup_api
        ;;

    pap | policy-pap)
        setup_pap
        ;;

    apex-pdp | policy-apex-pdp)
        setup_apex
        ;;

    xacml-pdp | policy-xacml-pdp)
        setup_xacml_pdp
        ;;

    opa-pdp | policy-opa-pdp)
        setup_opa_pdp
        ;;

    drools-pdp | policy-drools-pdp)
        setup_drools_pdp
        ;;

    drools-applications | policy-drools-applications | drools-apps | policy-drools-apps)
        setup_drools_apps
        ;;

    distribution | policy-distribution)
        setup_distribution
        ;;

    *)
        echo "Unknown project supplied. No test will run."
        exit 1
        ;;
    esac
}

# ensure that teardown and other finalizing steps are always executed
trap on_exit EXIT

# start the script

# Parse the command-line arguments
while [[ $# -gt 0 ]]
do
  key="$1"

  case $key in
    --skip-build-csit)
      export SKIP_BUILDING_ROBOT_IMG=true
      shift
      ;;
    --local)
      export USE_LOCAL_IMAGES=true
      shift
      ;;
    --no-exit)
      export DO_NOT_TEARDOWN=true
      shift
      ;;
    --stop)
      export TEARDOWN=true
      shift
      ;;
    --no-logs)
      export DONT_PRINT_LOGS=true
      shift
      ;;
    *)
      export PROJECT="${1}"
      shift
      ;;
  esac
done

# setup all directories used for test resources
if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

export GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' "${WORKSPACE}"/.gitreview)
export ROBOT_LOG_DIR="${WORKSPACE}/csit/archives/${PROJECT}"
export SCRIPTS="${WORKSPACE}/csit/resources/scripts"
export CSAR_DIR="${WORKSPACE}/csit/resources/tests/data/csar"
export DOCKER_COMPOSE_DIR="${WORKSPACE}/compose"
export ROBOT_FILES=""

cd "${WORKSPACE}" || exit

# recreate the log folder with test results
rm -rf "${ROBOT_LOG_DIR}"
mkdir -p "${ROBOT_LOG_DIR}"

# log into nexus docker
docker login -u docker -p docker nexus3.onap.org:10001

# based on $PROJECT var, setup robot test files and docker compose execution
compose_version=$(docker compose version)

if [[ $compose_version == *"Docker Compose version"* ]]; then
    echo "$compose_version"
else
    echo "Docker Compose Plugin not installed. Installing now..."
    sudo mkdir -p /usr/local/lib/docker/cli-plugins
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

if [ "${TEARDOWN}" == "true" ]; then
    on_exit
fi

set_project_config

unset http_proxy https_proxy

export ROBOT_FILES

# use a separate script to build a CSIT docker image, to isolate the test run
if [ "${SKIP_BUILDING_ROBOT_IMG}" == "true" ]; then
    echo "Skipping build csit robot image"
else
    build_robot_image
fi

docker_stats | tee "${ROBOT_LOG_DIR}/_sysinfo-1-after-setup.txt"

# start the CSIT container and run the tests
run_robot

docker ps --format "table {{ .Image }}\t{{ .Names }}\t{{ .Status }}"
