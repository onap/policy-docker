FROM ubuntu:14.04

ARG HTTP_PROXY=${HTTP_PROXY}
ARG HTTPS_PROXY=${HTTPS_PROXY}

ENV http_proxy $HTTP_PROXY
ENV https_proxy $HTTPS_PROXY

RUN \
	apt-get clean && \
	apt-get update && \
	apt-get install -y zip unzip curl wget ssh telnet maven && \
	apt-get install -y software-properties-common && \
	apt-get install -y jq httpie && \
	apt-get install -y python-pip && \
	add-apt-repository ppa:openjdk-r/ppa && \
	apt-get clean && \
	apt-get update && \
	apt-get install -y openjdk-8-jdk

RUN useradd --create-home --shell /bin/bash policy
