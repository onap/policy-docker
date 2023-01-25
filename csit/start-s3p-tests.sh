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

# This script will be used to automatically trigger the S3P
# tests for policy components.

# Start Kubernetes
function start_kubernetes() {
  bash run-k8s-csit.sh install
  bash get-cluster-info.sh
}

function install_jmeter() {

  #NOTE: $TESTDIR is set by the component triggering this script
  cd ${TESTDIR}/automate-performance

  sudo apt-get update

  # Install curl
  sudo apt install curl -y

  # Install JDK
  sudo apt install -y default-jdk

  # Install JMeter
  curl -O https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.3.tgz
  tar -xvf apache-jmeter-5.3.tgz

  # Remove unnecessary files
  rm -rf apache-jmeter-5.3/docs apache-jmeter-5.3/printable_docs

  # Install CMD Runner
  cd apache-jmeter-5.3/lib
  curl -O https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2.1/cmdrunner-2.2.1.jar

  # Install Plugin Manager
  cd ext/
  curl -O https://repo1.maven.org/maven2/kg/apc/jmeter-plugins-manager/1.6/jmeter-plugins-manager-1.6.jar

  # Download Plugins
  cd ..
  java  -jar cmdrunner-2.2.1.jar --tool org.jmeterplugins.repository.PluginManagerCMD install-all-except jpgc-hadoop,jpgc-oauth,ulp-jmeter-autocorrelator-plugin,ulp-jmeter-videostreaming-plugin,ulp-jmeter-gwt-plugin,tilln-iso8583

  # Move JMeter to /opt
  sudo cp -r ../../apache-jmeter-5.3 /opt/

  # Add JMeter Path Variable
  nano .profile
  JMETER_HOME="/opt/apache-jmeter-5.3"
  PATH="$JMETER_HOME/bin:$PATH"
  source ~/.profile
}

function on_exit() {
  # TODO: Generate report
  echo "Generating report..."
}

function teardown() {
  echo "Removing temp directories.."

  rm -r ${TESTDIR}/automate-performance

  echo "Removed directories"

  echo "Tearing down kubernetes cluster..."
  bash run-k8s-csit.sh uninstall

  # DELETE created services
  microk8s kubectl get svc | awk '/svc/{system("microk8s kubectl delete svc " $1)}'
}

#===MAIN===#

if [ $1 == "run" ]
then

  echo "==========================="
  echo "Starting K8s Environment"
  echo "==========================="
  start_kubernetes

  echo "==========================="
  echo "Installing JMeter"
  echo "==========================="
  install_jmeter

  # Run the JMX test plan
  echo "==========================="
  echo "Executing tests"
  echo "==========================="
  cd ${TESTDIR}/automate-performance || exit
  nohup apache-jmeter-5.3/bin/jmeter -n -t $2 -l s3pTestResults.jtl

  # TODO: Generate report on on_exit()

elif [ $1 == "uninstall" ]
then
  echo "Uninstalling environment and removing temp folders..."
  teardown
else
  echo "Invalid arguments provided. Usage: $0 [option..] {run | uninstall}"
fi

