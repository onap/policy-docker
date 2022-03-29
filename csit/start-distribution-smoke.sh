# ============LICENSE_START====================================================
# Copyright (C) 2022 Nordix Foundation.
# =============================================================================
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
#
# SPDX-License-Identifier: Apache-2.0
# ============LICENSE_END======================================================

SCRIPTS=$(git rev-parse --show-toplevel)
export SCRIPTS="${SCRIPTS}"/csit

cd ${SCRIPTS}

python3 ./prepare-config-files.py --https=false

source ./get-versions.sh

docker-compose -f docker-compose-distribution-smoke.yml up

distribution=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' policy-distribution)

echo "Distribution server: http://${distribution}:6969"