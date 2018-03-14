This source repository contains the files for building the ONAP Policy Engine Docker image policy-nexus. 

To build it using Maven 3, first build 'policy/common', 'policy/engine', 'policy/drools-pdp', and 'policy/drools-applications' repositories, and then run: mvn prepare-package. This will pull the installation zip files needed for building the policy-pe and policy-drools Docker images into the target directory.  It will not actually build the docker images; the following additional steps are needed to accomplish this:

To build the policy-nexus docker image, run the 'docker build' command on the following directory:
	policy-nexus

For example:
docker build -t onap/policy-nexus  policy-nexus

In addition, this source repository contains a docker-compose.yml file and associated configuration files (in the 'config' directory) that can be used to start up the ONAP Policy Engine docker containers

If you want to call the docker-compose, the following needs to be setup before doing so:

chmod +x config/drools/drools-tweaks.sh
IP_ADDRESS=$(ifconfig eth0 | grep "inet addr" | tr -s ' ' | cut -d' ' -f3 | cut -d':' -f2)
echo $IP_ADDRESS > config/pe/ip_addr.txt

If you do not want the policies pre-loaded, then set this environment variable to false:

export PRELOAD_POLICIES=false

It will override the settings in the .env file. Which is set to true.

