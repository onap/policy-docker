#!/bin/bash
#
# ============LICENSE_START===================================================
# Copyright (c) 2016 The Linux Foundation and others.
# Modification Copyright 2021. Nordix Foundation.
# Modification Copyright 2021 AT&T Intellectual Property. All rights reserved.
# ============================================================================
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
# ============LICENSE_END=====================================================
#

ROBOT_VENV=$(mktemp -d --suffix=robot_venv)
echo "ROBOT_VENV=${ROBOT_VENV}" >> "${WORKSPACE}/env.properties"

echo "Python version is: $(python3 --version)"

python3 -m venv "${ROBOT_VENV}"
source "${ROBOT_VENV}/bin/activate"

set -exu

# Make sure pip3 itself us up-to-date.
python3 -m pip install --upgrade pip

echo "Installing Python Requirements"
python3 -m pip install -r pylibs.txt
python3 -m pip freeze
