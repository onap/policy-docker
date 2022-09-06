#!/bin/bash -x
#
# Copyright 2016-2017 Huawei Technologies Co., Ltd.
# Modification Copyright 2019 © Samsung Electronics Co., Ltd.
# Modification Copyright 2021 © AT&T Intellectual Property.
# Modification Copyright 2021-2022 Nordix Foundation.
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
        if [[ ${WORKDIR} ]]; then
            rsync -av "${WORKDIR}/" "${WORKSPACE}/csit/archives/${PROJECT}"
        fi
        # Record list of active docker containers
        docker ps --format "{{.Image}}" > "${WORKSPACE}/csit/archives/${PROJECT}/_docker-images.log"

        # show memory consumption after all docker instances initialized
        docker_stats | tee "${WORKSPACE}/csit/archives/${PROJECT}/_sysinfo-2-after-robot.txt"
    fi
    # Run teardown script plan if it exists
    cd "${TESTPLANDIR}/plans/"
    TEARDOWN="${TESTPLANDIR}/plans/teardown.sh"
    if [ -f "${TEARDOWN}" ]; then
        echo "Running teardown script ${TEARDOWN}"
        source_safely "${TEARDOWN}"
    fi
    # TODO: do something with the output
     exit $rc
}

# ensure that teardown and other finalizing steps are always executed
trap on_exit EXIT

function docker_stats(){
    #General memory details
    echo "> top -bn1 | head -3"
    top -bn1 | head -3
    echo

    echo "> free -h"
    free -h
    echo

    #Memory details per Docker
    echo "> docker ps"
    docker ps
    echo

    echo "> docker stats --no-stream"
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
    export WORKSPACE=$(git rev-parse --show-toplevel)
fi

# Add csit scripts to PATH
export PATH="${PATH}:${WORKSPACE}/csit:${WORKSPACE}/scripts:${ROBOT_VENV}/bin"
export SCRIPTS="${WORKSPACE}/csit"
export ROBOT_VARIABLES=

# get the plan from git clone
source "${SCRIPTS}"/get-branch.sh

# Prepare configuration files
cd "${WORKSPACE}/csit"
python3 ./prepare-config-files.py --https=true

export PROJECT="${1}"

cd ${WORKSPACE}

export TESTPLANDIR="${WORKSPACE}/csit/${PROJECT}"
export TESTOPTIONS="${2}"

rm -rf "${WORKSPACE}/csit/archives/${PROJECT}"
mkdir -p "${WORKSPACE}/csit/archives/${PROJECT}"

# Run installation of prerequired libraries
source_safely "${SCRIPTS}/prepare-csit.sh"

# Activate the virtualenv containing all the required libraries installed by prepare-csit.sh
source_safely "${ROBOT_VENV}/bin/activate"

WORKDIR=$(mktemp -d --suffix=-robot-workdir)
cd "${WORKDIR}"

# Sign in to nexus3 docker repo
docker login -u docker -p docker nexus3.onap.org:10001

# Generate truststore and keystore to be used by repos
#${SCRIPTS}/gen_truststore.sh
#${SCRIPTS}/gen_keystore.sh
cp ${SCRIPTS}/config/ks.jks ${SCRIPTS}/config/drools/custom/policy-keystore
cp ${SCRIPTS}/config/ks.jks ${SCRIPTS}/config/drools-apps/custom/policy-keystore
cp ${SCRIPTS}/config/policy-truststore \
    ${SCRIPTS}/config/drools/custom/policy-truststore
cp ${SCRIPTS}/config/policy-truststore \
    ${SCRIPTS}/config/drools-apps/custom/policy-truststore
chmod 644 \
    ${SCRIPTS}/config/drools/custom/policy-* \
    ${SCRIPTS}/config/drools-apps/custom/policy-*

# Run setup script plan if it exists
cd "${TESTPLANDIR}/plans/"
SETUP="${TESTPLANDIR}/plans/setup.sh"
if [ -f "${SETUP}" ]; then
    echo "Running setup script ${SETUP}"
    source_safely "${SETUP}"
fi

# show memory consumption after all docker instances initialized
docker_stats | tee "${WORKSPACE}/csit/archives/${PROJECT}/_sysinfo-1-after-setup.txt"

# Run test plan
cd "${WORKDIR}"
echo "Reading the testplan:"
cat "${TESTPLANDIR}/plans/testplan.txt" | egrep -v '(^[[:space:]]*#|^[[:space:]]*$)' | sed "s|^|${TESTPLANDIR}/tests/|" > testplan.txt
cat testplan.txt
SUITES=$( xargs -a testplan.txt )

echo ROBOT_VARIABLES="${ROBOT_VARIABLES}"
echo "Starting Robot test suites ${SUITES} ..."
relax_set
python3 -m robot.run -N ${PROJECT} -v WORKSPACE:/tmp ${ROBOT_VARIABLES} ${SUITES}
RESULT=$?
load_set
echo "RESULT: ${RESULT}"
# Note that the final steps are done in on_exit function after this exit!
exit ${RESULT}
