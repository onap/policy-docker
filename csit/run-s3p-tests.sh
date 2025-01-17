#!/bin/bash
# ============LICENSE_START=======================================================
#  Copyright (C) 2023-2025 Nordix Foundation. All rights reserved.
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

script_start_time=$(date +%s)
log_file="${TESTDIR:-$(pwd)}/s3p_test_log_$(date +%Y%m%d_%H%M%S).log"
files_processed=0
errors_encountered=0
warnings_issued=0

# Function to log messages
log_message() {
    local level="$1"
    local message="$2"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $message" | tee -a "$log_file"
}

# Start Kubernetes
function start_kubernetes() {
    log_message "INFO" "Starting Kubernetes cluster for $PROJECT"
    bash resources/scripts/cluster_setup.sh install $PROJECT
    if [ $? -eq 0 ]; then
        log_message "INFO" "Kubernetes cluster started successfully"
    else
        log_message "ERROR" "Failed to start Kubernetes cluster"
        ((errors_encountered++))
    fi
    bash resources/scripts/get-cluster-info.sh
}

function install_jmeter() {
    log_message "INFO" "Installing JMeter"
    cd ${TESTDIR}/automate-s3p-test || { log_message "ERROR" "Failed to change directory"; ((errors_encountered++)); return 1; }

    sudo apt-get update
    sudo apt install curl -y
    sudo apt install -y default-jdk

    curl -O https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.2.tgz
    tar -xvf apache-jmeter-5.6.2.tgz
    mv apache-jmeter-5.6.2 apache-jmeter

    echo 'export JVM_ARGS="-Xms2g -Xmx4g"' > apache-jmeter/bin/setenv.sh
    echo 'export HEAP="-Xms1G -Xmx2G -XX:MaxMetaspaceSize=512m"' >> apache-jmeter/bin/setenv.sh

    rm -rf apache-jmeter/docs apache-jmeter/printable_docs

    cd apache-jmeter/lib || { log_message "ERROR" "Failed to change directory"; ((errors_encountered++)); return 1; }
    curl -O https://repo1.maven.org/maven2/kg/apc/cmdrunner/2.2.1/cmdrunner-2.2.1.jar
    curl -O https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.9.0/kafka-clients-3.9.0.jar
    curl -O https://repo1.maven.org/maven2/org/apache/kafka/kafka_2.13/3.9.0/kafka_2.13-3.9.0.jar

    sudo cp -r ../../apache-jmeter /opt/

    export JMETER_HOME="/opt/apache-jmeter"
    export PATH="$JMETER_HOME/bin:$PATH"

    log_message "INFO" "JMeter installation completed"
    ((files_processed+=7))
}

function on_exit() {
    local exit_status=$?
    local end_time=$(date +%s)
    local runtime=$((end_time - script_start_time))

    log_message "INFO" "=============== Exit Report ==============="
    log_message "INFO" "Script execution completed at $(date)"
    log_message "INFO" "Exit status: $exit_status"
    log_message "INFO" "Total runtime: $runtime seconds"
    log_message "INFO" "Operations summary:"
    log_message "INFO" "  - Files processed: $files_processed"
    log_message "INFO" "  - Errors encountered: $errors_encountered"
    log_message "INFO" "  - Warnings issued: $warnings_issued"
    log_message "INFO" "Resource usage:"
    ps -p $$ -o %cpu,%mem,etime >> "$log_file"
    log_message "INFO" "Full log available at: $log_file"
    log_message "INFO" "============================================"
}

function show_usage() {
    echo "Usage: $0 [option] {test <jmx_file> | clean}"
    echo "Options:"
    echo "  test <jmx_file>  Start the environment and run the specified JMX test plan"
    echo "  clean            Uninstall the environment and remove temporary folders"
}

function teardown() {
    log_message "INFO" "Starting teardown process"

    log_message "INFO" "Tearing down Kubernetes cluster"
    bash resources/scripts/cluster_setup.sh uninstall

    log_message "INFO" "Deleting created services"
    microk8s kubectl get svc | awk '/svc/{system("microk8s kubectl delete svc " $1)}'

    log_message "INFO" "Teardown process completed"
}

function main() {
    PROJECT="$3"
    case "$1" in
        clean)
            log_message "INFO" "Uninstalling environment and removing temp folders"
            teardown
            ;;
        test)
            if [ -z "$2" ]; then
                log_message "ERROR" "JMX file not specified for test option"
                show_usage
                ((errors_encountered++))
                exit 1
            fi
            log_message "INFO" "Starting K8s Environment"
            start_kubernetes

            log_message "INFO" "Installing JMeter"
            install_jmeter

            log_message "INFO" "Executing tests"
            cd "${TESTDIR}/automate-s3p-test" || { log_message "ERROR" "Failed to change directory"; ((errors_encountered++)); exit 1; }
            nohup jmeter -n -t "$2" -l s3pTestResults.jtl
            if [ $? -eq 0 ]; then
                log_message "INFO" "JMeter test completed successfully"
                ((files_processed++))
            else
                log_message "ERROR" "JMeter test failed"
                ((errors_encountered++))
            fi
            ;;
        *)
            log_message "WARNING" "Invalid option provided"
            show_usage
            ((warnings_issued++))
            exit 1
            ;;
    esac
}

# Set TESTDIR if not already set
TESTDIR=${TESTDIR:-$(pwd)}

# Set up trap for exit
trap on_exit EXIT

# Call the main function with all script arguments
main "$@"
