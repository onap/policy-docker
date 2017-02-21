#!/bin/bash
#
echo '============== STARTING SCRIPT TO BUILD DOCKER IMAGES ================='


DOCKER_REPOSITORY=nexus3.openecomp.org:10003
DOCKER_VERSION=latest

cp policy-pe/* target/policy-pe/
cp policy-drools/* target/policy-drools/

for image in policy-os policy-nexus policy-db policy-base policy-drools policy-pe ; do
    echo "Building $image"
    mkdir -p target/$image
    cp $image/* target/$image
    docker build --quiet --tag openecomp/policy/$image:${DOCKER_VERSION} target/$image
    docker images
done

for image in policy-nexus policy-db policy-drools policy-pe; do
    echo "Pushing $image"
    docker push openecomp/policy/$image:${DOCKER_VERSION}
done
