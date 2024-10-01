#!/bin/bash
#
# ============LICENSE_START====================================================
#  Copyright (C) 2022-2024 Nordix Foundation.
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

WORKSPACE=$(git rev-parse --show-toplevel)
export WORKSPACE

export GERRIT_BRANCH=$(awk -F= '$1 == "defaultbranch" { print $2 }' "${WORKSPACE}"/.gitreview)

CSIT_SCRIPT="scripts/run-test.sh"
ROBOT_DOCKER_IMAGE="policy-csit-robot"
POLICY_CLAMP_ROBOT="policy-clamp-test.robot clamp-slas.robot"
POLICY_API_ROBOT="api-test.robot api-slas.robot"
POLICY_PAP_ROBOT="pap-test.robot pap-slas.robot"
POLICY_APEX_PDP_ROBOT="apex-pdp-test.robot apex-slas.robot"
POLICY_XACML_PDP_ROBOT="xacml-pdp-test.robot xacml-pdp-slas.robot"
POLICY_DROOLS_PDP_ROBOT="drools-pdp-test.robot"
POLICY_DISTRIBUTION_ROBOT="distribution-test.robot"

POLICY_API_CONTAINER="policy-api"
POLICY_PAP_CONTAINER="policy-pap"
POLICY_CLAMP_CONTAINER="policy-clamp-runtime-acm"
POLICY_APEX_CONTAINER="policy-apex-pdp"
POLICY_DROOLS_CONTAINER="policy-drools-pdp"
POLICY_XACML_CONTAINER="policy-xacml-pdp"
POLICY_DISTRIBUTION_CONTAINER="policy-distribution"
POLICY_K8S_PPNT_CONTAINER="policy-clamp-ac-k8s-ppnt"
POLICY_HTTP_PPNT_CONTAINER="policy-clamp-ac-http-ppnt"
POLICY_SIM_PPNT_CONTAINER="policy-clamp-ac-sim-ppnt"
POLICY_PF_PPNT_CONTAINER="policy-clamp-ac-pf-ppnt"
JAEGER_CONTAINER="jaeger"
KAFKA_CONTAINER="kafka-deployment"
ZK_CONTAINER="zookeeper-deployment"
KAFKA_DIR=${WORKSPACE}/helm/cp-kafka
SET_VALUES=""

DISTRIBUTION_CSAR=${WORKSPACE}/csit/resources/tests/data/csar
DIST_TEMP_FOLDER=/tmp/distribution

export PROJECT=""
export ROBOT_FILE=""
export ROBOT_LOG_DIR=${WORKSPACE}/csit/archives
export READINESS_CONTAINERS=()


function spin_microk8s_cluster() {
    echo "Verify if Microk8s cluster is running.."
    microk8s version
    exitcode="${?}"

    if [ "$exitcode" -ne 0 ]; then
        echo "Microk8s cluster not available, Spinning up the cluster.."
        sudo snap install microk8s --classic --channel=1.30/stable

        if [ "${?}" -ne 0 ]; then
            echo "Failed to install kubernetes cluster. Aborting.."
            return 1
        fi
        echo "Microk8s cluster installed successfully"
        sudo usermod -a -G microk8s $USER
        echo "Enabling DNS and Storage plugins"
        sudo microk8s.enable dns hostpath-storage
        echo "Creating configuration file for Microk8s"
        sudo mkdir -p $HOME/.kube
        sudo chown -R $USER:$USER $HOME/.kube
        sudo microk8s kubectl config view --raw >$HOME/.kube/config
        sudo chmod 600 $HOME/.kube/config
        echo "K8s installation completed"
        echo "----------------------------------------"
    else
        echo "K8s cluster is already running"
        echo "----------------------------------------"
    fi

    echo "Verify if kubectl is running.."
    kubectl version
    exitcode="${?}"

    if [ "$exitcode" -ne 0 ]; then
        echo "Kubectl not available, Installing.."
        sudo snap install kubectl --classic --channel=1.30/stable

        if [ "${?}" -ne 0 ]; then
            echo "Failed to install Kubectl. Aborting.."
            return 1
        fi
        echo "Kubectl installation completed"
        echo "----------------------------------------"
    else
        echo "Kubectl is already running"
        echo "----------------------------------------"
        return 0
    fi

    echo "Verify if helm is running.."
    helm version
    exitcode="${?}"

    if [ "$exitcode" -ne 0 ]; then
        echo "Helm not available, Installing.."
        sudo snap install helm --classic --channel=3.7

        if [ "${?}" -ne 0 ]; then
            echo "Failed to install Helm client. Aborting.."
            return 1
        fi
        echo "Helm installation completed"
        echo "----------------------------------------"
    else
        echo "Helm is already running"
        echo "----------------------------------------"
        return 0
    fi
}

function install_kafka() {
  echo "Installing Confluent kafka"
  kubectl apply -f $KAFKA_DIR/zookeeper.yaml
  kubectl apply -f $KAFKA_DIR/kafka.yaml
  echo "----------------------------------------"
}

function uninstall_policy() {
    echo "Removing the policy helm deployment"
    helm uninstall csit-policy
    helm uninstall prometheus
    helm uninstall csit-robot
    kubectl delete deploy $ZK_CONTAINER $KAFKA_CONTAINER
    rm -rf ${WORKSPACE}/helm/policy/Chart.lock
    if [ "$PROJECT" == "clamp" ] || [ "$PROJECT" == "policy-clamp" ]; then
      helm uninstall policy-chartmuseum
      helm repo remove chartmuseum-git policy-chartmuseum
    fi
    sudo rm -rf /dockerdata-nfs/mariadb-galera/
    kubectl delete pvc --all
    echo "Policy deployment deleted"
    echo "Clean up docker"
    docker image prune -f
}

function teardown_cluster() {
    echo "Removing k8s cluster and k8s configuration file"
    sudo snap remove microk8s;rm -rf $HOME/.kube/config
    sudo snap remove helm;
    sudo snap remove kubectl;
    echo "MicroK8s Cluster removed"
}

function build_robot_image() {
    echo "Build docker image for robot framework"
    cd ${WORKSPACE}/csit/resources || exit
    clone_models
    if [ "${PROJECT}" == "distribution" ] || [ "${PROJECT}" == "policy-distribution" ]; then
        copy_csar_file
    fi
    echo "Build robot framework docker image"
    docker login -u docker -p docker nexus3.onap.org:10001
    docker build . --file Dockerfile \
        --build-arg CSIT_SCRIPT="$CSIT_SCRIPT" \
        --build-arg ROBOT_FILE="$ROBOT_FILE" \
        --tag "${ROBOT_DOCKER_IMAGE}" --no-cache
    echo "---------------------------------------------"
}

function start_csit() {
    build_robot_image
    if [ "${?}" -eq 0 ]; then
        echo "Importing robot image into microk8s registry"
        docker save -o policy-csit-robot.tar ${ROBOT_DOCKER_IMAGE}:latest
        sudo microk8s ctr image import policy-csit-robot.tar
        rm -rf ${WORKSPACE}/csit/resources/policy-csit-robot.tar
        rm -rf ${WORKSPACE}/csit/resources/tests/models/
        echo "---------------------------------------------"
        if [ "$PROJECT" == "clamp" ] || [ "$PROJECT" == "policy-clamp" ]; then
          POD_READY_STATUS="0/1"
          while [[ ${POD_READY_STATUS} != "1/1" ]]; do
            echo "Waiting for chartmuseum pod to come up..."
            sleep 5
            POD_READY_STATUS=$(kubectl get pods | grep -e "policy-chartmuseum" | awk '{print $2}')
          done
          push_acelement_chart
        fi
        echo "Installing Robot framework pod for running CSIT"
        cd ${WORKSPACE}/helm
        mkdir -p ${ROBOT_LOG_DIR}
        helm install csit-robot robot --set robot="$ROBOT_FILE" --set "readiness={${READINESS_CONTAINERS[*]}}" --set robotLogDir=$ROBOT_LOG_DIR
        print_robot_log
    fi
}

function print_robot_log() {
    count_pods=0
    while [[ ${count_pods} -eq 0 ]]; do
        echo "Waiting for pods to come up..."
        sleep 5
        count_pods=$(kubectl get pods --output name | wc -l)
    done
    robotpod=$(kubectl get po | grep policy-csit)
    podName=$(echo "$robotpod" | awk '{print $1}')
    echo "The robot tests will begin once the policy components {${READINESS_CONTAINERS[*]}} are up and running..."
    kubectl wait --for=jsonpath='{.status.phase}'=Running --timeout=18m pod/"$podName"
    echo "Policy deployment status:"
    kubectl get po
    kubectl get all -A
    echo "Robot Test logs:"
    kubectl logs -f "$podName"
}

function clone_models() {

    # download models examples
    git clone -b "${GERRIT_BRANCH}" --single-branch https://github.com/onap/policy-models.git "${WORKSPACE}"/csit/resources/tests/models

    # create a couple of variations of the policy definitions
    sed -e 's!Measurement_vGMUX!ADifferentValue!' \
        tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.json \
        >tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.v1_2.json

    sed -e 's!"version": "1.0.0"!"version": "2.0.0"!' \
        -e 's!"policy-version": 1!"policy-version": 2!' \
        tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.json \
        >tests/models/models-examples/src/main/resources/policies/vCPE.policy.monitoring.input.tosca.v2.json
}

function copy_csar_file() {
    zip -F ${DISTRIBUTION_CSAR}/sample_csar_with_apex_policy.csar \
        --out ${DISTRIBUTION_CSAR}/csar_temp.csar -q
    # Remake temp directory
    sudo rm -rf "${DIST_TEMP_FOLDER}"
    sudo mkdir "${DIST_TEMP_FOLDER}"
    sudo cp ${DISTRIBUTION_CSAR}/csar_temp.csar ${DISTRIBUTION_CSAR}/temp.csar
    sudo mv ${DISTRIBUTION_CSAR}/temp.csar ${DIST_TEMP_FOLDER}/sample_csar_with_apex_policy.csar
}

function set_project_config() {
    echo "Setting project configuration for: $PROJECT"
    case $PROJECT in

    clamp | policy-clamp)
        export ROBOT_FILE=$POLICY_CLAMP_ROBOT
        export READINESS_CONTAINERS=($POLICY_CLAMP_CONTAINER,$POLICY_APEX_CONTAINER,$POLICY_PF_PPNT_CONTAINER,$POLICY_K8S_PPNT_CONTAINER,
            $POLICY_HTTP_PPNT_CONTAINER,$POLICY_SIM_PPNT_CONTAINER,$JAEGER_CONTAINER)
        export SET_VALUES="--set $POLICY_CLAMP_CONTAINER.enabled=true --set $POLICY_APEX_CONTAINER.enabled=true
            --set $POLICY_PF_PPNT_CONTAINER.enabled=true --set $POLICY_K8S_PPNT_CONTAINER.enabled=true
            --set $POLICY_HTTP_PPNT_CONTAINER.enabled=true --set $POLICY_SIM_PPNT_CONTAINER.enabled=true
            --set $JAEGER_CONTAINER.enabled=true"
        install_chartmuseum
        ;;

    api | policy-api)
        export ROBOT_FILE=$POLICY_API_ROBOT
        export READINESS_CONTAINERS=($POLICY_API_CONTAINER)
        ;;

    pap | policy-pap)
        export ROBOT_FILE=$POLICY_PAP_ROBOT
        export READINESS_CONTAINERS=($POLICY_APEX_CONTAINER,$POLICY_PAP_CONTAINER,$POLICY_API_CONTAINER,$POLICY_XACML_CONTAINER)
        export SET_VALUES="--set $POLICY_APEX_CONTAINER.enabled=true --set $POLICY_XACML_CONTAINER.enabled=true"
        ;;

    apex-pdp | policy-apex-pdp)
        export ROBOT_FILE=$POLICY_APEX_PDP_ROBOT
        export READINESS_CONTAINERS=($POLICY_APEX_CONTAINER,$POLICY_API_CONTAINER,$POLICY_PAP_CONTAINER)
        export SET_VALUES="--set $POLICY_APEX_CONTAINER.enabled=true"
        ;;

    xacml-pdp | policy-xacml-pdp)
        export ROBOT_FILE=($POLICY_XACML_PDP_ROBOT)
        export READINESS_CONTAINERS=($POLICY_API_CONTAINER,$POLICY_PAP_CONTAINER,$POLICY_XACML_CONTAINER)
        export SET_VALUES="--set $POLICY_XACML_CONTAINER.enabled=true"
        ;;

    drools-pdp | policy-drools-pdp)
        export ROBOT_FILE=($POLICY_DROOLS_PDP_ROBOT)
        export READINESS_CONTAINERS=($POLICY_DROOLS_CONTAINER)
        export SET_VALUES="--set $POLICY_DROOLS_CONTAINER.enabled=true"
        ;;

    distribution | policy-distribution)
        export ROBOT_FILE=($POLICY_DISTRIBUTION_ROBOT)
        export READINESS_CONTAINERS=($POLICY_APEX_CONTAINER,$POLICY_API_CONTAINER,$POLICY_PAP_CONTAINER,$POLICY_DISTRIBUTION_CONTAINER)
        export SET_VALUES="--set $POLICY_APEX_CONTAINER.enabled=true --set $POLICY_DISTRIBUTION_CONTAINER.enabled=true"
        ;;

    *)
        echo "Unknown project supplied. Enabling all policy charts for the deployment"
        export READINESS_CONTAINERS=($POLICY_APEX_CONTAINER,$POLICY_API_CONTAINER,$POLICY_PAP_CONTAINER,
                    $POLICY_DISTRIBUTION_CONTAINER,$POLICY_DROOLS_CONTAINER,$POLICY_XACML_CONTAINER,
                    $POLICY_CLAMP_CONTAINER,$POLICY_PF_PPNT_CONTAINER,$POLICY_K8S_PPNT_CONTAINER,
                    $POLICY_HTTP_PPNT_CONTAINER,$POLICY_SIM_PPNT_CONTAINER)
        export SET_VALUES="--set $POLICY_APEX_CONTAINER.enabled=true --set $POLICY_XACML_CONTAINER.enabled=true
            --set $POLICY_DISTRIBUTION_CONTAINER.enabled=true --set $POLICY_DROOLS_CONTAINER.enabled=true
            --set $POLICY_CLAMP_CONTAINER.enabled=true --set $POLICY_PF_PPNT_CONTAINER.enabled=true
            --set $POLICY_K8S_PPNT_CONTAINER.enabled=true --set $POLICY_HTTP_PPNT_CONTAINER.enabled=true
            --set $POLICY_SIM_PPNT_CONTAINER.enabled=true"
        ;;
    esac

}

function install_chartmuseum () {
    echo "---------------------------------------------"
    echo "Installing Chartmuseum helm repository..."
    helm repo add chartmuseum-git https://chartmuseum.github.io/charts
    helm repo update
    helm install policy-chartmuseum chartmuseum-git/chartmuseum --set env.open.DISABLE_API=false --set service.type=NodePort --set service.nodePort=30208
    helm plugin install https://github.com/chartmuseum/helm-push
    echo "---------------------------------------------"
}

function push_acelement_chart() {
    echo "Pushing acelement chart to the chartmuseum repo..."
    helm repo add policy-chartmuseum http://localhost:30208

    # download clamp repo
    git clone -b "${GERRIT_BRANCH}" --single-branch https://github.com/onap/policy-clamp.git "${WORKSPACE}"/csit/resources/tests/clamp
    ACELEMENT_CHART=${WORKSPACE}/csit/resources/tests/clamp/examples/src/main/resources/clamp/acm/acelement-helm/acelement
    helm cm-push $ACELEMENT_CHART policy-chartmuseum
    helm repo update
    rm -rf ${WORKSPACE}/csit/resources/tests/clamp/
    echo "-------------------------------------------"
}

function get_pod_name() {
  pods=$(kubectl get pods --no-headers -o custom-columns=':metadata.name' | grep $1)
  read -rd '' -a pod_array <<< "$pods"
  echo "${pod_array[@]}"
}

wait_for_pods_running() {
  local namespace="$1"
  shift
  local timeout_seconds="$1"
  shift

  IFS=',' read -ra pod_names <<< "$@"
  shift

  local pending_pods=("${pod_names[@]}")
  local start_time
  start_time=$(date +%s)

  while [ ${#pending_pods[@]} -gt 0 ]; do
    local current_time
    current_time=$(date +%s)
    local elapsed_time
    elapsed_time=$((current_time - start_time))

    if [ "$elapsed_time" -ge "$timeout_seconds" ]; then
      echo "Timed out waiting for the pods to reach 'Running' state."
      echo "Printing the current status of the deployment before exiting.."
      kubectl get po;
      kubectl describe pods;
      echo "------------------------------------------------------------"
      for pod in "${pending_pods[@]}"; do
        echo "Logs of the pod $pod"
        kubectl logs $pod
        echo "---------------------------------------------------------"
      done
      exit 1
    fi

    local newly_running_pods=()

    for pod_name_prefix in "${pending_pods[@]}"; do
      local pod_names=$(get_pod_name "$pod_name_prefix")
      IFS=' ' read -r -a pod_array <<< "$pod_names"
      if [ "${#pod_array[@]}" -eq 0 ]; then
             echo "*** Error: No pods found for the deployment $pod_name_prefix . Exiting ***"
             return -1
      fi
      for pod in "${pod_array[@]}"; do
         local pod_status
         local pod_ready
         pod_status=$(kubectl get pod "$pod" -n "$namespace" --no-headers -o custom-columns=STATUS:.status.phase 2>/dev/null)
         pod_ready=$(kubectl get pod "$pod" -o jsonpath='{.status.containerStatuses[*].ready}')

         if [ "$pod_status" == "Running" ] && [ "$pod_ready" == "true" ]; then
           echo "Pod '$pod' in namespace '$namespace' is now in 'Running' state and 'Readiness' is true"
         else
           newly_running_pods+=("$pod")
           echo "Waiting for pod '$pod' in namespace '$namespace' to reach 'Running' and 'Ready' state..."
         fi

      done
    done

    pending_pods=("${newly_running_pods[@]}")

    sleep 5
  done

  echo "All specified pods are in the 'Running and Ready' state. Exiting the function."
}

OPERATION="$1"
PROJECT="$2"
if [ -z "$3" ]
then
    LOCALIMAGE="false"
else
    LOCALIMAGE="$3"
fi


if [ $OPERATION == "install" ]; then
    spin_microk8s_cluster
    if [ "${?}" -eq 0 ]; then
        export KAFKA_CONTAINERS=($KAFKA_CONTAINER,$ZK_CONTAINER)
        install_kafka
        wait_for_pods_running default 300 $KAFKA_CONTAINERS
        set_project_config
        echo "Installing policy helm charts in the default namespace"
        source ${WORKSPACE}/compose/get-k8s-versions.sh
        if [ $LOCALIMAGE == "true" ]; then
            echo "loading local image"
            source ${WORKSPACE}/compose/get-versions.sh
            ${WORKSPACE}/compose/loaddockerimage.sh
        fi
        cd ${WORKSPACE}/helm || exit
        helm dependency build policy
        helm install csit-policy policy ${SET_VALUES}
        helm install prometheus prometheus
        wait_for_pods_running default 900 ${READINESS_CONTAINERS[@]}
        echo "Policy chart installation completed"
        echo "-------------------------------------------"
    fi

    if [ "$PROJECT" ]; then
        export ROBOT_LOG_DIR=${WORKSPACE}/csit/archives/${PROJECT}
        echo "CSIT will be invoked from $ROBOT_FILE"
        echo "Readiness containers: ${READINESS_CONTAINERS[*]}"
        echo "-------------------------------------------"
        start_csit
    else
        echo "No project supplied for running CSIT"
    fi

elif [ $OPERATION == "uninstall" ]; then
    uninstall_policy

elif [ $OPERATION == "clean" ]; then
    teardown_cluster

else
    echo "Invalid arguments provided. Usage: $0 [options..] {install {project_name} | uninstall | clean} {uselocalimage = true/false}"
fi
