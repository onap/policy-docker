#!/bin/bash -ex
#   ============LICENSE_START=======================================================
#    Copyright (C) 2019 ENEA AB. All rights reserved.
#   ================================================================================
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
#   SPDX-License-Identifier: Apache-2.0
#   ============LICENSE_END=========================================================

REGISTRY='docker.io'
IMAGE_NAME=$1
IMAGE_TAG=$2

#create the template to be used with the manifest list
mkdir -p "$(dirname "${IMAGE_NAME}")"
cat > "${IMAGE_NAME}_${IMAGE_TAG}.yaml" <<EOF
image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}
manifests:
  -
    image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}-amd64
    platform:
      architecture: amd64
      os: linux
  -
    image: ${REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}-aarch64
    platform:
      architecture: arm64
      os: linux
EOF
