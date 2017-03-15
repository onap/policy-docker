#!/bin/bash
#
echo '============== STARTING SCRIPT TO BUILD DOCKER IMAGES ================='

DOCKER_REPOSITORY=nexus3.openecomp.org:10003
MVN_VERSION=$(cat target/version)
TIMESTAMP=$(date -u +%Y%m%dT%H%M%S)

echo $DOCKER_REPOSITORY
echo $MVN_VERSION
echo $TIMESTAMP

cp policy-pe/* target/policy-pe/
cp policy-drools/* target/policy-drools/

for image in policy-os policy-nexus policy-db policy-base policy-drools policy-pe ; do
    echo "Building $image"
    mkdir -p target/$image
    cp $image/* target/$image

    TAGS="--tag openecomp/policy/${image}:latest"
    TAGS="${TAGS} --tag ${DOCKER_REPOSITORY}/openecomp/policy/${image}:latest"
    TAGS="${TAGS} --tag ${DOCKER_REPOSITORY}/openecomp/policy/${image}:${MVN_VERSION}-latest"
    TAGS="${TAGS} --tag openecomp/policy/${image}:${MVN_VERSION}-${TIMESTAMP}"
    TAGS="${TAGS} --tag ${DOCKER_REPOSITORY}/openecomp/policy/${image}:${MVN_VERSION}-${TIMESTAMP}"

    echo $TAGS
done

#for image in policy-nexus policy-db policy-drools policy-pe; do
#    echo "Pushing $image"
##    docker push ${DOCKER_REPOSITORY}/openecomp/policy/$image:${MVN_VERSION}-latest
#    docker push ${DOCKER_REPOSITORY}/openecomp/policy/$image:${MVN_VERSION}-${TIMESTAMP}
#done
