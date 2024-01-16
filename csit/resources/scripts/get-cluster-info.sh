#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2023 Nordix Foundation. All rights reserved.
# ================================================================================
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
# ============LICENSE_END=========================================================

# This script will be used to gather cluster information
# for JMeter to work towards the installed cluster

# EXPLICITLY ASSIGN PORTS FOR TESTING PURPOSES
export APEX_PORT=30001
export API_PORT=30002
export PAP_PORT=30003
export XACML_PORT=30004
export DROOLS_PORT=30005
export DIST_PORT=30006
export ACM_PORT=30007
export POLICY_PF_PARTICIPANT_PORT=30008
export POLICY_HTTP_PARTICIPANT_PORT=30009
export POLICY_K8S_PARTICIPANT_PORT=30010
export SIMULATOR_PORT=30904

# Retrieve pod names
function get_pod_names() {
  export APEX_POD=$(get_pod_name apex)
  export PAP_POD=$(get_pod_name pap)
  export API_POD=$(get_pod_name api)
  export DMAAP_POD=$(get_pod_name message-router)
  export XACML_POD=$(get_pod_name xacml)
  export DROOLS_POD=$(get_pod_name drools-pdp)
  export DIST_POD=$(get_pod_name distribution)
  export ACM_POD=$(get_pod_name acm-runtime)
  export POLICY_PPNT_POD=$(get_pod_name policy-ppnt)
  export POLICY_PPNT_POD=$(get_pod_name http-ppnt)
  export POLICY_PPNT_POD=$(get_pod_name k8s-ppnt)
}

# Retrieve service names
function get_svc_names() {
  export APEX_SVC=$(get_svc_name policy-apex-pdp)
  export PAP_SVC=$(get_svc_name policy-pap)
  export API_SVC=$(get_svc_name policy-api)
  export DMAAP_SVC=$(get_svc_name message-router)
  export DROOLS_SVC=$(get_svc_name drools-pdp)
  export XACML_SVC=$(get_svc_name policy-xacml-pdp)
  export DIST_SVC=$(get_svc_name policy-distribution)
  export ACM_SVC=$(get_svc_name policy-clamp-runtime-acm)
  export POLICY_PPNT_SVC=$(get_svc_name policy-clamp-ac-pf-ppnt)
  export POLICY_HTTP_SVC=$(get_svc_name policy-clamp-ac-http-ppnt)
  export POLICY_K8S_SVC=$(get_svc_name policy-clamp-ac-k8s-ppnt)
}

# Expose services in order to perform tests from JMeter
function expose_services() {
    expose_service $APEX_SVC
    expose_service $PAP_SVC
    expose_service $API_SVC
    expose_service $XACML_SVC
    expose_service $DROOLS_SVC
    expose_service $DIST_SVC
    expose_service $ACM_SVC
    expose_service $POLICY_PPNT_SVC
    expose_service POLICY_HTTP_SVC
    expose_service POLICY_K8S_SVC

    setup_message_router_svc
    sleep 2
    patch_ports
}

function get_pod_name() {
  microk8s kubectl get pods --no-headers -o custom-columns=':metadata.name' | grep $1
}

function get_svc_name() {
  microk8s kubectl get svc --no-headers -o custom-columns=':metadata.name' | grep $1
}

function expose_service() {
  microk8s kubectl expose service $1 --name $1"-svc" --type NodePort --protocol TCP --port 6969 --target-port 6969
}

function patch_port() {
  microk8s kubectl patch service "$1-svc" --namespace=default --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":'"$2"'}]'
}

# Assign set port values
function patch_ports() {
  patch_port "$APEX_SVC" $APEX_PORT
  patch_port "$API_SVC" $API_PORT
  patch_port "$PAP_SVC" $PAP_PORT
  patch_port "$ACM_SVC" $ACM_PORT
  patch_port "$POLICY_PPNT_SVC" $POLICY_PF_PARTICIPANT_PORT
  patch_port "$HTTP_PPNT_SVC" $POLICY_HTTP_PARTICIPANT_PORT
  patch_port "$K8S_PPNT_SVC" $POLICY_K8S_PARTICIPANT_PORT
  patch_port "$DIST_SVC" $DIST_PORT
  patch_port "$DROOLS_SVC" $DROOLS_PORT
  patch_port "$XACML_SVC" $XACML_PORT
}

function setup_message_router_svc() {
  microk8s kubectl expose service message-router --name message-router-svc --type NodePort --protocol TCP --port 3904 --target-port 3904
  microk8s kubectl patch service message-router-svc --namespace=default --type='json' --patch='[{"op": "replace", "path": "/spec/ports/0/nodePort", "value":'"$SIMULATOR_PORT"'}]'
}

####MAIN###
get_pod_names
get_svc_names
expose_services
