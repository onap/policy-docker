This source repository contains the files for building the ONAP Policy Engine Docker images.

To build it using Maven 3, first build 'policy/common', 'policy/engine', 'policy/drools-pdp', and 'policy/drools-applications' repositories, and then run: mvn prepare-package. This will pull the installation zip files needed for building the policy-pe and policy-drools Docker images into the target directory.  It will not actually build the docker images; the following additional steps are needed to accomplish this:

- Copy the files under policy-pe to target/policy-pe
- Copy the files under policy-drools to target/policy-drools
- Run the 'docker build' command on the following directories, in order:
	policy-os
	policy-nexus
	policy-base
	target/policy-pe
	target/policy-drools

For example:
docker build -t onap/policy/policy-os     policy-os
docker build -t onap/policy/policy-nexus  policy-nexus
docker build -t onap/policy/policy-base   policy-base
docker build -t onap/policy/policy-pe     target/policy-pe
docker build -t onap/policy/policy-drools target/policy-drools

In addition, the 'config' directory contains configuration files that are read during the startup of the containers; this directory is referenced by the docker-compose.yml file.

If you want to call the docker-compose, the following needs to be setup before doing so:

chmod +x config/drools/drools-tweaks.sh
IP_ADDRESS=$(ifconfig eth0 | grep "inet addr" | tr -s ' ' | cut -d' ' -f3 | cut -d':' -f2)
echo $IP_ADDRESS > config/pe/ip_addr.txt

If you do not want the policies pre-loaded, then set this environment variable to false:

export PRELOAD_POLICIES=false

It will override the settings in the .env file. Which is set to true.

