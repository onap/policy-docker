#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 © Samsung Electronics Co., Ltd.
# Modification Copyright 2021 © AT&T Intellectual Property.
# Modification Copyright 2021-2024 Nordix Foundation.
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
    docker ps --format "table {{ .Names }}\t{{ .Status }}"
    echo

    docker stats --no-stream
    echo
}

function setup_clamp() {
    export ROBOT_FILES="policy-clamp-test.robot clamp-slas.robot"
    source "${WORKSPACE}"/compose/start-compose.sh policy-clamp-runtime-acm --grafana
    sleep 30
    bash "${SCRIPTS}"/wait_for_rest.sh localhost "${ACM_PORT}"
}

function setup_clamp_replica() {
    export ROBOT_FILES="policy-clamp-test.robot"
    export TEST_ENV="docker"
    source "${WORKSPACE}"/compose/start-acm-replica.sh 2
    sleep 30
    bash "${SCRIPTS}"/wait_for_rest.sh localhost "${ACM_PORT}"
}

function setup_api() {
    export ROBOT_FILES="api-test.robot api-slas.robot"
    source "${WORKSPACE}"/compose/start-compose.sh api --grafana
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${API_PORT}
}

function setup_pap() {
    export ROBOT_FILES="pap-test.robot pap-slas.robot"
    source "${WORKSPACE}"/compose/start-compose.sh apex-pdp --grafana
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
}

function setup_apex() {
    export ROBOT_FILES="apex-pdp-test.robot apex-slas.robot"
    source "${WORKSPACE}"/compose/start-compose.sh apex-pdp --grafana
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${APEX_PORT}
    apex_healthcheck
}

function setup_apex_postgres() {
    export ROBOT_FILES="apex-pdp-test.robot"
    source "${WORKSPACE}"/compose/start-postgres-tests.sh apex-pdp 1
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${APEX_PORT}
    apex_healthcheck
}

function setup_apex_medium() {
    export SUITES="apex-slas-3.robot"
    source "${WORKSPACE}"/compose/start-multiple-pdp.sh 3
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${APEX_PORT}
    apex_healthcheck
}

function setup_apex_large() {
    export ROBOT_FILES="apex-slas-10.robot"
    source "${WORKSPACE}"/compose/start-multiple-pdp.sh 10
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${APEX_PORT}
    apex_healthcheck
}

function apex_healthcheck() {
    sleep 20

    healthy=false

    while [ $healthy = false ]
    do
        msg=`curl -s -k --user 'policyadmin:zb!XztG34' http://localhost:${APEX_PORT}/policy/apex-pdp/v1/healthcheck`
        echo "${msg}" | grep -q true
        if [ "${?}" -eq 0 ]
        then
            healthy=true
            break
        fi
        sleep 10s
    done
}

function setup_drools_apps() {
    export ROBOT_FILES="drools-applications-test.robot"
    source "${WORKSPACE}"/compose/start-compose.sh drools-applications
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${PAP_PORT}
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${DROOLS_APPS_PORT}
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${DROOLS_APPS_TELEMETRY_PORT}
}

function setup_xacml_pdp() {
    export ROBOT_FILES="xacml-pdp-test.robot"
    source "${WORKSPACE}"/compose/start-compose.sh xacml-pdp
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost "${XACML_PORT}"
}

function setup_xacml_pdp_postgres() {
    export ROBOT_FILES="xacml-pdp-test.robot"
    source "${WORKSPACE}"/compose/start-postgres-tests.sh xacml-pdp 1
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost "${XACML_PORT}"
}

function setup_drools_pdp() {
    export ROBOT_FILES="drools-pdp-test.robot"
    source "${WORKSPACE}"/compose/start-compose.sh drools-pdp
    sleep 30
    bash "${SCRIPTS}"/wait_for_rest.sh localhost ${DROOLS_TELEMETRY_PORT}
}

function setup_distribution() {
    zip -F ${WORKSPACE}/csit/resources/tests/data/csar/sample_csar_with_apex_policy.csar \
        --out ${WORKSPACE}/csit/resources/tests/data/csar/csar_temp.csar -q

    # Remake temp directory
    sudo rm -rf /tmp/distribution
    sudo mkdir /tmp/distribution

    export ROBOT_FILES="distribution-test.robot"
    source "${WORKSPACE}"/compose/start-compose.sh distribution
    sleep 10
    bash "${SCRIPTS}"/wait_for_rest.sh localhost "${DIST_PORT}"
}

function build_robot_image() {
    bash "${SCRIPTS}"/build-csit-docker-image.sh
    cd ${WORKSPACE}
}

function run_robot() {
    docker compose -f "${WORKSPACE}"/compose/docker-compose.yml up csit-tests
    export RC=$?
}

function set_project_config() {
    echo "Setting project configuration for: $PROJECT"
    case $PROJECT in

    clamp | policy-clamp)
        setup_clamp
        ;;

    clamp-replica | policy-clamp-replica)
        setup_clamp_replica
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

    apex-pdp-postgres | policy-apex-pdp-postgres)
        setup_apex_postgres
        ;;

    apex-pdp-medium | policy-apex-pdp-medium)
        setup_apex_medium
        ;;

    apex-pdp-large | policy-apex-pdp-large)
        setup_apex_large
        ;;

    xacml-pdp | policy-xacml-pdp)
        setup_xacml_pdp
        ;;

    xacml-pdp-postgres | policy-xacml-pdp-postgres)
        setup_xacml_pdp_postgres
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

# even with forced finish, clean up docker containers
function on_exit(){
    rm -rf ${WORKSPACE}/csit/resources/tests/data/csar/csar_temp.csar
    source ${WORKSPACE}/compose/stop-compose.sh
    cp ${WORKSPACE}/compose/*.log ${WORKSPACE}/csit/archives/${PROJECT}
    exit $RC
}

# ensure that teardown and other finalizing steps are always executed
trap on_exit EXIT

# setup all directories used for test resources
if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

export GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' "${WORKSPACE}"/.gitreview)
export PROJECT="${1}"
export ROBOT_LOG_DIR=${WORKSPACE}/csit/archives/${PROJECT}
export SCRIPTS="${WORKSPACE}/csit/resources/scripts"
export ROBOT_FILES=""
# always 'docker' if running docker compose
export TEST_ENV="docker"

cd "${WORKSPACE}"

# recreate the log folder with test results
sudo rm -rf ${ROBOT_LOG_DIR}
mkdir -p ${ROBOT_LOG_DIR}

# log into nexus docker
docker login -u docker -p docker nexus3.onap.org:10001

# based on $PROJECT var, setup robot test files and docker compose execution
compose_version=$(docker compose version)

if [[ $compose_version == *"Docker Compose version"* ]]; then
    echo $compose_version
else
    echo "Docker Compose Plugin not installed. Installing now..."
    sudo mkdir -p /usr/local/lib/docker/cli-plugins
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
    sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose
fi

set_project_config

unset http_proxy https_proxy

export ROBOT_FILES

# use a separate script to build a CSIT docker image, to isolate the test run
if [ "${2}" == "--skip-build-csit" ]; then
    echo "Skipping build csit robot image"
else
    build_robot_image
fi

docker_stats | tee "${WORKSPACE}/csit/archives/${PROJECT}/_sysinfo-1-after-setup.txt"

# start the CSIT container and run the tests
run_robot

docker ps --format "table {{ .Names }}\t{{ .Status }}"
