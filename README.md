Copyright 2018-2019 AT&T Intellectual Property. All rights reserved.
This file is licensed under the CREATIVE COMMONS ATTRIBUTION 4.0 INTERNATIONAL LICENSE
Full license text at https://creativecommons.org/licenses/by/4.0/legalcode

This source repository contains legacy docker-compose configurations used for CSIT
tests, and ONAP Heat instantiations.

Additionally, the policy-base/ and policy-common/ projects are used to generate 
the OS base for policy images.

Helm directory is added to include the helm chart for policy-models-simulators.
To spin the kubernetes pod up: 
1. Edit the name of the docker image that needs to be pulled in the values.yaml
2. Execute the below commands:
    helm package policy-models-simulator
    helm install --name <releaseName> policy-models-simulator 