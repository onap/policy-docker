FROM ecomp-nexus:51220/policy/policy-os

RUN \
	apt-get install -y apt-transport-https && \
	apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db && \
	add-apt-repository 'deb [arch=amd64,i386,ppc64el] https://mirrors.evowise.com/mariadb/repo/10.1/ubuntu trusty main' && \
	apt-get update && \
	apt-get install -y mariadb-server && \
	touch /var/lib/mysql/firstrun

COPY dbinit.sh do-start.sh /tmp/
RUN bash /tmp/dbinit.sh

# mount volumes to persist the data
VOLUME /etc/mysql /var/lib/mysql

CMD exec bash /tmp/do-start.sh
