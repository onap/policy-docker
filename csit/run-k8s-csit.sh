#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2022 Nordix Foundation.
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

# This script spins up kubernetes cluster in Microk8s for deploying policy helm charts.
# Runs CSITs in kubernetes.

CSIT_SCRIPT="run-test.sh"
ROBOT_DOCKER_IMAGE="policy-csit-robot"
POLICY_CLAMP_ROBOT="policy-clamp-test.robot"
POLICY_API_ROBOT="api-test.robot"
POLICY_PAP_ROBOT="pap-test.robot"
POLICY_APEX_PDP_ROBOT="apex-pdp-test.robot"
POLICY_XACML_PDP_ROBOT="xacml-pdp-test.robot"
POLICY_DROOLS_PDP_ROBOT="drools-pdp-test.robot"
POLICY_API_CONTAINER="policy-api"
POLICY_PAP_CONTAINER="policy-pap"
POLICY_CLAMP_CONTAINER="policy-clamp-runtime-acm"
POLICY_APEX_CONTAINER="policy-apex-pdp"

export PROJECT=""
export ROBOT_FILE=""
export READINESS_CONTAINER=""

function spin_microk8s_cluster () {
    echo "Verify if Microk8s cluster is running.."
    microk8s version
    exitcode="${?}"

    if [ "$exitcode" -ne 0 ];  then
        echo "Microk8s cluster not available, Spinning up the cluster.."
        sudo snap install microk8s --classic --channel=1.25/stable

	      if [ "${?}" -ne 0 ];  then
	          echo "Failed to install kubernetes cluster. Aborting.."
		        return 1
        fi
        echo "Microk8s cluster installed successfully"
        sudo usermod -a -G microk8s $USER
        echo "Enabling DNS and helm3 plugins"
        microk8s.enable dns helm3
        echo "Creating configuration file for Microk8s"
        microk8s kubectl config view --raw > $HOME/.kube/config
        chmod 600 $HOME/.kube/config
        echo "K8s installation completed"
        echo "----------------------------------------"
    else
        echo "K8s cluster is already running"
        echo "----------------------------------------"
	      return 0
    fi

}


function teardown_cluster () {
    echo "Removing k8s cluster and k8s configuration file"
    sudo snap remove microk8s;rm -rf $HOME/.kube/config
    sudo rm -rf /dockerdata-nfs/mariadb-galera/
    echo "K8s Cluster removed"
}


function build_robot_image () {
    echo "Build docker image for robot framework"
    cd ../helm;
    clone_models
    echo "Build robot framework docker image"
    docker login -u docker -p docker nexus3.onap.org:10001
    docker build . --file Dockerfile --build-arg CSIT_SCRIPT="$CSIT_SCRIPT" --build-arg ROBOT_FILE="$ROBOT_FILE"  --tag "${ROBOT_DOCKER_IMAGE}" --no-cache
    echo "---------------------------------------------"
    echo "Importing robot image in to microk8s registry"
    docker save -o policy-csit-robot.tar ${ROBOT_DOCKER_IMAGE}:latest
    microk8s ctr image import policy-csit-robot.tar
    if [ "${?}" -eq 0 ]; then
        rm -rf policy-csit-robot.tar
        rm -rf tests/models/
        echo "---------------------------------------------"
        echo "Installing Robot framework pod for running CSIT"
        helm install csit-robot robot --set robot=$ROBOT_FILE --set readiness=$READINESS_CONTAINER;
        echo "Please check the logs of policy-csit-robot pod for the test execution results"
    fi
}

function clone_models () {
    GIT_TOP=$(git rev-parse --show-toplevel)
    GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' \
                    "${GIT_TOP}"/.gitreview)
    echo GERRIT_BRANCH="${GERRIT_BRANCH}"
    # download models examples
    git clone -b "${GERRIT_BRANCH}" --single-branch https://github.com/onap/policy-models.git tests/models
}


function get_robot_file () {
  case $PROJECT in

  clamp | policy-clamp)
    export ROBOT_FILE=$POLICY_CLAMP_ROBOT
    export READINESS_CONTAINER=$POLICY_CLAMP_CONTAINER
    ;;

  api | policy-api)
    export ROBOT_FILE=$POLICY_API_ROBOT
    export READINESS_CONTAINER=$POLICY_API_CONTAINER
    ;;

  pap | policy-pap)
    export ROBOT_FILE=$POLICY_PAP_ROBOT
    export READINESS_CONTAINER=$POLICY_PAP_CONTAINER
    ;;

  apex-pdp | policy-apex-pdp)
    export ROBOT_FILE=$POLICY_APEX_PDP_ROBOT
    export READINESS_CONTAINER=$POLICY_APEX_CONTAINER
    ;;

  xacml-pdp | policy-xacml-pdp)
    export ROBOT_FILE=$POLICY_XACML_PDP_ROBOT
    ;;

  drools-pdp | policy-drools-pdp)
    export ROBOT_FILE=$POLICY_DROOLS_PDP_ROBOT
    ;;

  *)
    echo "unknown project supplied"
    ;;
esac

}


if [ $1 == "install" ];  then
    spin_microk8s_cluster
    if [ "${?}" -eq 0 ];  then
        echo "Installing policy helm charts in the default namespace"
        cd ../helm/;helm dependency build policy;microk8s helm install csit-policy policy;
        echo "Policy chart installation completed"
	      echo "-------------------------------------------"
    fi

    if [ "$2" ]; then
        export PROJECT=$2
        get_robot_file
        echo "CSIT will be invoked from $ROBOT_FILE"
        echo "Readiness container: $READINESS_CONTAINER"
        build_robot_image
    else
        echo "No project supplied for running CSIT"
    fi

elif [ $1 == "uninstall" ];  then
    teardown_cluster
else
    echo "Invalid arguments provided. Usage: $0 [option..] {install {project} | uninstall}"
fi

