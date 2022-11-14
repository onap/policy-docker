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
        echo "Enabling DNS and helm3"
        microk8s.enable dns helm3
        echo "Creating configuration file for Microk8s"
        microk8s kubectl config view --raw > $HOME/.kube/config
        chmod 600 $HOME/.kube/config
        echo "K8s installation completed"
    else
        echo "K8s cluster is already running"
	      return 0
    fi

}

function teardown_cluster () {
    echo "Removing k8s cluster and k8s configuration file"
    sudo snap remove microk8s;rm -rf $HOME/.kube/config
    echo "K8s Cluster removed"
}


if [ $1 == "install" ];  then
    spin_microk8s_cluster
    if [ "${?}" -eq 0 ];  then
        echo "Installing policy helm charts in the default namespace"
        cd ../helm/;helm dependency build policy;microk8s helm install dev-policy policy;
        echo "Policy chart installation completed"
    fi

elif [ $1 == "uninstall" ];  then
    teardown_cluster
else
    echo "Invalid arguments provided. Usage: $0 [option..] {install | uninstall}"
fi

