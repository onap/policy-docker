#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 © Samsung Electronics Co., Ltd.
# Modification Copyright 2021 © AT&T Intellectual Property.
# Modification Copyright 2021-2024 Nordix Foundation.
# Modifications Copyright 2024 Deutsche Telekom
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

# even with forced finish, clean up docker containers
function on_exit(){
    rm -rf ${CSAR_DIR}/csar_temp.csar

    # teardown of compose containers for acm-replicas doesn't work with normal stop-compose script
    if [ "${ACM_REPLICA_TEARDOWN}" = true ]; then
        source ${DOCKER_COMPOSE_DIR}/start-acm-replica.sh --stop --replicas=2
    elif [ "${APEX_REPLICA_TEARDOWN}" = true ]; then
        source ${DOCKER_COMPOSE_DIR}/start-multiple-pdp.sh --stop --replicas=2
    else
        source ${DOCKER_COMPOSE_DIR}/stop-compose.sh ${PROJECT}
    fi

    mv ${DOCKER_COMPOSE_DIR}/*.log ${ROBOT_LOG_DIR}
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
        msg=`curl -s -k --user 'policyadmin:zb!XztG34' http://localhost:${APEX_PORT}/policy/apex-pdp/v1/healthcheck`
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
    bash ${SCRIPTS}/wait_for_rest.sh localhost "${1}"
    rc=$?
    if [ $rc -ne 0 ]; then
        on_exit
    fi
}

function setup_clamp() {
    export ROBOT_FILES="policy-clamp-test.robot clamp-slas.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh policy-clamp-runtime-acm --grafana
    sleep 30
    check_rest_endpoint "${ACM_PORT}"
}

function setup_clamp_replica() {
    export ACM_REPLICA_TEARDOWN=true
    export ROBOT_FILES="policy-clamp-test.robot"
    export TEST_ENV="docker"
    export PROJECT=clamp
    source ${DOCKER_COMPOSE_DIR}/start-acm-replica.sh --start --replicas=2
    echo "Waiting a minute for the replicas to be started..."
    sleep 60
    # checking on apex-pdp status because acm-r replicas only start after apex-pdp is running
    check_rest_endpoint ${PAP_PORT}
    check_rest_endpoint ${APEX_PORT}
    apex_healthcheck
    check_rest_endpoint ${ACM_PORT}
}

function setup_api() {
    export ROBOT_FILES="api-test.robot api-slas.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh api --grafana
    sleep 10
    check_rest_endpoint ${API_PORT}
}

function setup_pap() {
    export ROBOT_FILES="pap-test.robot pap-slas.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh apex-pdp --grafana
    sleep 10
    check_rest_endpoint ${PAP_PORT}
}

function setup_apex() {
    export ROBOT_FILES="apex-pdp-test.robot apex-slas.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh apex-pdp --grafana
    sleep 10
    check_rest_endpoint ${PAP_PORT}
    check_rest_endpoint ${APEX_PORT}
    apex_healthcheck
}

function setup_apex_medium() {
    export SUITES="apex-slas-3.robot"
    export APEX_REPLICA_TEARDOWN=true
    source ${DOCKER_COMPOSE_DIR}/start-multiple-pdp.sh --start --replicas=3
    sleep 10
    check_rest_endpoint ${PAP_PORT}
    check_rest_endpoint ${APEX_PORT}
    apex_healthcheck
}

function setup_apex_large() {
    export ROBOT_FILES="apex-slas-10.robot"
    export APEX_REPLICA_TEARDOWN=true
    source ${DOCKER_COMPOSE_DIR}/start-multiple-pdp.sh --start --replicas=10
    sleep 10
    check_rest_endpoint ${PAP_PORT}
    check_rest_endpoint ${APEX_PORT}
    apex_healthcheck
}

function setup_drools_apps() {
    export ROBOT_FILES="drools-applications-test.robot drools-applications-slas.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh drools-applications --grafana
    sleep 10
    check_rest_endpoint ${PAP_PORT}
    sleep 10
    check_rest_endpoint ${DROOLS_APPS_PORT}
    sleep 10
    check_rest_endpoint ${DROOLS_APPS_TELEMETRY_PORT}
}

function setup_xacml_pdp() {
    export ROBOT_FILES="xacml-pdp-test.robot xacml-pdp-slas.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh xacml-pdp --grafana
    sleep 10
    check_rest_endpoint "${XACML_PORT}"
}

function setup_opa_pdp() {
    export ROBOT_FILES="opa-pdp-test.robot"
    export PROJECT="opa-pdp"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh opa-pdp --grafana
    sleep 180
    bash ${SCRIPTS}/wait_for_rest.sh localhost "${OPA_PDP_PORT}"
}

function setup_drools_pdp() {
    export ROBOT_FILES="drools-pdp-test.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh drools-pdp --grafana
    sleep 30
    check_rest_endpoint ${DROOLS_TELEMETRY_PORT}
}

function setup_distribution() {
    zip -F ${CSAR_DIR}/sample_csar_with_apex_policy.csar --out ${CSAR_DIR}/csar_temp.csar -q

    # Remake temp directory
    sudo rm -rf /tmp/distribution
    sudo mkdir /tmp/distribution

    export ROBOT_FILES="distribution-test.robot"
    source ${DOCKER_COMPOSE_DIR}/start-compose.sh distribution --grafana
    sleep 10
    check_rest_endpoint "${DIST_PORT}"
}

function build_robot_image() {
    bash ${SCRIPTS}/build-csit-docker-image.sh
    cd ${WORKSPACE}
}

function run_robot() {
    docker compose -f ${DOCKER_COMPOSE_DIR}/compose.yaml up csit-tests
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
        setup_apex
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

# setup all directories used for test resources
if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

export GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' "${WORKSPACE}"/.gitreview)
export PROJECT="${1}"
export ROBOT_LOG_DIR="${WORKSPACE}/csit/archives/${PROJECT}"
export SCRIPTS="${WORKSPACE}/csit/resources/scripts"
export CSAR_DIR="${WORKSPACE}/csit/resources/tests/data/csar"
export DOCKER_COMPOSE_DIR="${WORKSPACE}/compose"
export ROBOT_FILES=""
export ACM_REPLICA_TEARDOWN=false
export APEX_REPLICA_TEARDOWN=false

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
    sudo curl -SL https://github.com/docker/compose/releases/download/v2.29.1/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
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

docker_stats | tee "${ROBOT_LOG_DIR}/_sysinfo-1-after-setup.txt"

# start the CSIT container and run the tests
run_robot

docker ps --format "table {{ .Image }}\t{{ .Names }}\t{{ .Status }}"
