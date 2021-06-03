#!/bin/bash -x
#
# Copyright 2019 © Samsung Electronics Co., Ltd.
# Modification Copyright 2021 © AT&T Intellectual Property.
# Modification Copyright 2021. Nordix Foundation.
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
# This script installs common libraries required by CSIT tests
#

if [ -z "$WORKSPACE" ]; then
    export WORKSPACE=`git rev-parse --show-toplevel`
fi

# Assume that if ROBOT_VENV is set and virtualenv with system site packages can be activated,
# include-raw-integration-install-robotframework.sh has already been executed

if [ -f ${WORKSPACE}/env.properties ]; then
    source ${WORKSPACE}/env.properties
fi
if [ -f ${ROBOT_VENV}/bin/activate ]; then
    source ${ROBOT_VENV}/bin/activate
else
<<<<<<< HEAD   (58fcc9 Use python3 for CSITs)
    rm -rf /tmp/ci-management
    rm -f ${WORKSPACE}/env.properties
    cd /tmp
    git clone -b master --single-branch https://github.com/onap/ci-management.git
    source /tmp/ci-management/jjb/integration/include-raw-integration-install-robotframework.sh
=======
    source ./include-raw-integration-install-robotframework.sh
>>>>>>> CHANGE (8f44cb Use local version of the include script)
fi


# install eteutils
mkdir -p ${ROBOT_VENV}/src/onap
rm -rf ${ROBOT_VENV}/src/onap/testsuite
pip3 install --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==0.5.1.*' --pre

pip3 freeze
