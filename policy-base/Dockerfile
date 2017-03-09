FROM openecomp/policy/policy-os


# install MariaDB client
RUN \
    apt-get install -y apt-transport-https && \
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
	add-apt-repository 'deb [arch=amd64,i386,ppc64el] http://ftp.osuosl.org/pub/mariadb/repo/10.0/ubuntu trusty main' && \
	apt-get clean && \
	apt-get update && \
	apt-get install -y mariadb-client
	

