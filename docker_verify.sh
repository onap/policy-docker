#!/bin/bash
#
echo '============== STARTING SCRIPT TO BUILD DOCKER IMAGES ================='
#
# JUST VERIFY ONLY - NO PUSHING
#
DOCKER_REPOSITORY=nexus3.onap.org:10003
MVN_VERSION=$(cat target/version)
MVN_MAJMIN_VERSION=$(cut -f 1,2 -d . target/version)
TIMESTAMP=$(date -u +%Y%m%dT%H%M%S)
PROXY_ARGS=""

if [ $HTTP_PROXY ]; then
    PROXY_ARGS+="--build-arg HTTP_PROXY=${HTTP_PROXY}"
fi
if [ $HTTPS_PROXY ]; then
    PROXY_ARGS+=" --build-arg HTTPS_PROXY=${HTTPS_PROXY}"
fi

echo $DOCKER_REPOSITORY
echo $MVN_VERSION
echo $MVN_MAJMIN_VERSION
echo $TIMESTAMP

if [[ -z $MVN_VERSION ]]
then
    echo "MVN_VERSION is empty"
    exit 1
fi

if [[ -z $MVN_MAJMIN_VERSION ]]
then
    echo "MVN_MAJMIN_VERSION is empty"
    exit 1
fi

if [[ $MVN_VERSION == *"SNAPSHOT"* ]]
then
    MVN_MAJMIN_VERSION="${MVN_MAJMIN_VERSION}-SNAPSHOT"
else
    MVN_MAJMIN_VERSION="${MVN_MAJMIN_VERSION}-STAGING"
fi

echo $MVN_MAJMIN_VERSION

cp policy-pe/* target/policy-pe/
cp policy-drools/* target/policy-drools/

for image in policy-os policy-nexus policy-base policy-drools policy-pe ; do
    echo "Building $image"
    mkdir -p target/$image
    cp $image/* target/$image

    #
    # This is the local latest tagged image. The Dockerfile's need this to build images
    #
    TAGS="--tag onap/policy/${image}:latest"
    #
    # This has the nexus repo prepended and only major/minor version with latest
    #
    TAGS="${TAGS} --tag ${DOCKER_REPOSITORY}/onap/policy/${image}:${MVN_MAJMIN_VERSION}-latest"
    #
    # This has the nexus repo prepended and major/minor/patch version with timestamp
    #
    TAGS="${TAGS} --tag ${DOCKER_REPOSITORY}/onap/policy/${image}:${MVN_VERSION}-${TIMESTAMP}"

    echo $TAGS

    docker build --quiet ${PROXY_ARGS} $TAGS target/$image

    if [ $? -ne 0 ]
    then
        echo "Docker build failed"
        docker images
        exit 1
    fi
done

docker images

