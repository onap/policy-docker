Copyright 2018-2019 AT&T Intellectual Property. All rights reserved.
This file is licensed under the CREATIVE COMMONS ATTRIBUTION 4.0 INTERNATIONAL LICENSE
Full license text at https://creativecommons.org/licenses/by/4.0/legalcode

This source repository contains legacy docker-compose configurations used for CSIT
tests, and ONAP Heat instantiations.

Additionally, the policy-base/ and policy-common/ projects are used to generate 
the OS base for policy images.

Helm directory is added to include the helm chart for policy-models-simulators.
To spin the kubernetes pod up:
1. Execute the below commands:
    helm upgrade -i <release_name> policy-models-simulator
    

Running Policy CSIT in kubernetes:
  To run CSIT in kubernetes, docker/csit/run-k8s-csit.sh script can be invoked with the arguments {install} {project_name}
  When the project name is not supplied, the script only installs the policy helm charts and doesn't execute any robot tests.
  To teardown the kubernetes cluster, the same script can be invoked with the argument {uninstall}
  
Steps involved in running CSIT in kubernetes:
  1. The script verifies microk8s based kubernetes cluster is running in the system and deploys kubernetes if required.
  2. Deploys policy helm charts under the default namespace.
  3. Builds docker image of the robot framework and deploys robot framework helm chart in the default namespace.
  4. Invokes the respective robot test file for the project supplied by the user. 
     The test execution results can be viewed from the logs of policy-csit-robot pod.