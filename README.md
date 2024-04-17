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

Running Policy CSIT in docker:
To run CSIT in docker, docker/csit/run-project-csit.sh script can be invoked with the argument {project_name}.

Running Policy Regression Tests:
  ACM regression tests can be invoked using the script docker/csit/run-acm-regression.sh with the arguments {ACM-R release name} {participant release name}
  For example, if ACM-R and participants needs to be tested for backward compatbility between montreal and london versions, the script can be invoked 
  with the command "./run-acm-regression.sh montreal london"
  This will deploy ACM-R and other policy components in montreal version and the participants in london version before invoking the test suite.
  The script can also be invoked without any arguments to deploy all the components in the default version of the repo.
