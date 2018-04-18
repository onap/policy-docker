Copyright 2018 AT&T Intellectual Property. All rights reserved.
This file is licensed under the CREATIVE COMMONS ATTRIBUTION 4.0 INTERNATIONAL LICENSE
Full license text at https://creativecommons.org/licenses/by/4.0/legalcode

This source repository contains the files for the ONAP Policy docker-compose configuration

The following needs to be setup before using docker-compose:

chmod +x config/drools/drools-tweaks.sh
IP_ADDRESS=$(ifconfig eth0 | grep "inet addr" | tr -s ' ' | cut -d' ' -f3 | cut -d':' -f2)
echo $IP_ADDRESS > config/pe/ip_addr.txt

If you do not want the policies pre-loaded, then set this environment variable to false:

export PRELOAD_POLICIES=false

It will override the settings in the .env file. Which is set to true.

