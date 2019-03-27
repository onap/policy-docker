#
# Docker file to build an image that contains commom packages for Policy apps
#
FROM onap/policy-base-alpine

LABEL maintainer="Policy Team"

ARG HTTP_PROXY=${HTTP_PROXY}
ARG HTTPS_PROXY=${HTTPS_PROXY}
ARG BUILD_VERSION=${BUILD_VERSION}

ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY
ENV BUILD_VERSION ${BUILD_VERSION}
ENV POLICY_HOME=/opt/app/policy

# Install common packages used in 6 out of 7 images
RUN apk add --no-cache \
    busybox-extras \
    httpie \
    jq \
    maven \
    py-pip \
    python

# Create policy user and group
RUN addgroup -S policy && \
    adduser -S  --shell /bin/bash -G policy policy

# Create common directories and change owner
RUN mkdir -p \
    ${POLICY_HOME}/etc/ssl \
    && chown  -R policy:policy ${POLICY_HOME} ${POLICY_HOME}/etc/ssl

