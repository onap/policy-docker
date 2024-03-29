#!/bin/bash
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 © Samsung Electronics Co., Ltd.
# Modification Copyright 2021 © AT&T Intellectual Property.
# Modification Copyright 2021-2023 Nordix Foundation.
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
# $1 functionality
# $2 robot options

#
# functions
#

function on_exit(){
    rc=$?
    if [[ ${WORKSPACE} ]]; then
        # Record list of active docker containers
        docker ps --format "table {{ .Names }}\t{{ .Status }}"

        # show memory consumption after all docker instances initialized
        docker_stats

        source_safely ${WORKSPACE}/compose/stop-compose.sh

        if [[ ${WORKDIR} ]]; then
            rsync -av "${WORKDIR}/" "${WORKSPACE}/csit/archives/${PROJECT}"
        fi
        rm -rf ${WORKSPACE}/models
    fi
    # TODO: do something with the output
     exit $rc
}

# ensure that teardown and other finalizing steps are always executed
trap on_exit EXIT

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

# save current set options
function save_set() {
    RUN_CSIT_SAVE_SET="$-"
    RUN_CSIT_SHELLOPTS="${SHELLOPTS}"
}

# load the saved set options
function load_set() {
    _setopts="$-"

    # bash shellopts
    for i in $(echo "${SHELLOPTS}" | tr ':' ' ') ; do
        set +o ${i}
    done
    for i in $(echo "${RUN_CSIT_SHELLOPTS}" | tr ':' ' ') ; do
        set -o ${i}
    done

    # other options
    for i in $(echo "$_setopts" | sed 's/./& /g') ; do
        set +${i}
    done
    set -${RUN_CSIT_SAVE_SET}
}

# set options for quick bailout when error
function harden_set() {
    set -xeo pipefail
    set +u # enabled it would probably fail too many often
}

# relax set options so the sourced file will not fail
# the responsibility is shifted to the sourced file...
function relax_set() {
    set +e
    set +o pipefail
}

# wrapper for sourcing a file
function source_safely() {
    [ -z "$1" ] && return 1
    relax_set
    . "$1"
    load_set
}

#
# main
#

# set and save options for quick failure
harden_set && save_set

if [ $# -eq 0 ]
then
    echo
    echo "Usage: $0 <project> [<robot-options>]"
    echo
    echo "    <project> <robot-options>:  "
    echo
    exit 1
fi

if [ -z "${WORKSPACE}" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

# Add csit scripts to PATH
export PATH="${PATH}:${WORKSPACE}/csit:${WORKSPACE}/scripts:${ROBOT_VENV}/bin"
export SCRIPTS="${WORKSPACE}/csit/resources/scripts"
export ROBOT_VARIABLES=

export PROJECT="${1}"

cd "${WORKSPACE}"

rm -rf "${WORKSPACE}/csit/archives/${PROJECT}"
mkdir -p "${WORKSPACE}/csit/archives/${PROJECT}"

# Run installation of pre-required libraries
source_safely "${SCRIPTS}/prepare-robot-env.sh"

# Activate the virtualenv containing all the required libraries installed by prepare-robot-env.sh
source_safely "${ROBOT_VENV}/bin/activate"

export TEST_PLAN_DIR="${WORKSPACE}/csit/resources/tests"
export TEST_OPTIONS="${2}"

WORKDIR=$(mktemp -d)
cd "${WORKDIR}"

# Sign in to nexus3 docker repo
docker login -u docker -p docker nexus3.onap.org:10001

# Run setup script plan if it exists
SETUP="${SCRIPTS}/setup-${PROJECT}.sh"
if [ -f "${SETUP}" ]; then
    echo "Running setup script ${SETUP}"
    source_safely "${SETUP}"
fi

# show memory consumption after all docker instances initialized
docker_stats | tee "${WORKSPACE}/csit/archives/${PROJECT}/_sysinfo-1-after-setup.txt"

# Run test plan
cd "${WORKDIR}"
echo "Reading the testplan:"
echo "${SUITES}" | egrep -v '(^[[:space:]]*#|^[[:space:]]*$)' | sed "s|^|${TEST_PLAN_DIR}/|" > testplan.txt
cat testplan.txt
SUITES=$( xargs < testplan.txt )

echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ${SUITES} ..."
relax_set
python3 -m robot.run -N "${PROJECT}" -v WORKSPACE:/tmp ${ROBOT_VARIABLES} ${SUITES}
RESULT=$?
load_set
echo "RESULT: ${RESULT}"
# Note that the final steps are done in on_exit function after this exit!
exit ${RESULT}
