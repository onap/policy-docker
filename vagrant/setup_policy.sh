#!/usr/bin/env bash
# Copyright 2018 AT&T Intellectual Property. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    sudo docker build -t onap/$comp packages/docker/target/$comp 
done

cd $HOME
git clone http://gerrit.onap.org/r/policy/docker
cd docker

sudo docker build -t onap/policy-nexus policy-nexus

cd $HOME/docker
chmod +x config/drools/drools-tweaks.sh
echo 192.168.0.10 > config/pe/ip_addr.txt
export MTU=1500
sudo -E docker-compose up -d
