FROM ubuntu:14.04

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
