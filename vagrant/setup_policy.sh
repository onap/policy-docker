#!/usr/bin/env bash

set -ex

sudo apt-get update -y
sudo apt-get install -y maven openjdk-8-jdk npm python-pip docker.io
sudo pip install docker-compose

git clone http://gerrit.onap.org/r/oparent
mkdir $HOME/.m2
cp oparent/settings.xml $HOME/.m2

for comp in common drools-pdp drools-applications engine
do
    cd $HOME
    git clone http://gerrit.onap.org/r/policy/$comp
    cd $comp
    mvn clean install
done

for comp in policy-pe policy-drools
do
    cd $HOME/$comp
    sudo docker build -t onap/policy/$comp packages/docker/target/$comp 
done

cd $HOME
git clone http://gerrit.onap.org/r/policy/docker
cd docker

sudo docker build -t onap/policy/policy-nexus policy-nexus

cd $HOME/docker
chmod +x config/drools/drools-tweaks.sh
echo 192.168.0.10 > config/pe/ip_addr.txt
export MTU=1500
sudo -E docker-compose up -d
