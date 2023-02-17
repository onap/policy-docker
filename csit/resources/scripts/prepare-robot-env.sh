#!/bin/bash -x
#
# Copyright 2019 © Samsung Electronics Co., Ltd.
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
# This script installs common libraries required by CSIT tests
#

if [ -z "$WORKSPACE" ]; then
    WORKSPACE=$(git rev-parse --show-toplevel)
    export WORKSPACE
fi

ROBOT_VENV=$(mktemp -d)
echo "ROBOT_VENV=${ROBOT_VENV}" >> "${WORKSPACE}/env.properties"

echo "Python version is: $(python3 --version)"

python3 -m venv --clear "${ROBOT_VENV}"
source "${ROBOT_VENV}/bin/activate" > /dev/null

set -exu

python3 -m pip install -qq --upgrade pip setuptools
echo "Installing Python Requirements"
python3 -m pip install -qq -r "${SCRIPTS}"/pylibs.txt
python3 -m pip -qq freeze

# install eteutils
mkdir -p "${ROBOT_VENV}"/src/onap
rm -rf "${ROBOT_VENV}"/src/onap/testsuite
python3 -m pip install -qq --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==0.5.1.*' --pre

echo "Uninstall docker-py and reinstall docker."
python3 -m pip uninstall -y -qq docker-py
python3 -m pip uninstall -y -qq docker
python3 -m pip install -U -qq docker

python3 -m pip -qq freeze

sudo apt-get -y -qq install libxml2-utils
