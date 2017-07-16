#!/usr/bin/env bash

set -ex

sudo apt-get update -y
sudo apt-get install -y maven openjdk-8-jdk npm python-pip docker.io
sudo pip install docker-compose

for comp in common drools-pdp drools-applications engine
do
    cd $HOME
    git clone http://gerrit.onap.org/r/policy/$comp
    cd $comp
    mvn clean install
done

cd $HOME
git clone http://gerrit.onap.org/r/policy/docker
cd docker
mvn prepare-package
cp -r target/policy-pe/* policy-pe/
cp -r target/policy-drools/* policy-drools

for comp in policy-os policy-db policy-nexus policy-base policy-pe policy-drools
do
    sudo docker build -t onap/policy/$comp $HOME/docker/$comp
done

cd $HOME/docker
chmod +x config/drools/drools-tweaks.sh
echo 192.168.0.10 > config/pe/ip_addr.txt
export MTU=1500
sudo -E docker-compose up -d
