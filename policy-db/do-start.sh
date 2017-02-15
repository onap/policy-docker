#! /bin/bash

# determine IP pattern associated with 'eth0' (assume net mask = 255.255.0.0)
ipPattern=$(ifconfig eth0|sed -n -e 's/^.*inet addr:\([^\.]*.[^\.]*\)\..*$/\1.%.%/p')

# start MySQL, and grant all privileges to the local network
# (it doesn't hurt to do the 'grant' multiple times)
service mysql start
mysql -uroot -psecret \
	-e "grant all privileges on *.* to 'policy_user'@'${ipPattern}' identified by 'policy_user' with grant option;"

exec sleep 1000d
