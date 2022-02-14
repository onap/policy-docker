#!/bin/bash
#
# ============LICENSE_START===================================================
#  Copyright (C) 2020-2021 AT&T Intellectual Property. All rights reserved.
#  Modifications Copyright 2022 Nordix Foundation.
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

source "${SCRIPTS}"/get-branch.sh

rm -rf "${WORKSPACE}"/models
mkdir "${WORKSPACE}"/models
cd "${WORKSPACE}"

# download models examples
git clone -b "${GERRIT_BRANCH}" --single-branch https://github.com/onap/policy-models.git models
