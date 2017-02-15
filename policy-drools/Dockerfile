FROM ecomp-nexus:51220/policy/policy-base

RUN mkdir -p /opt/app/policy /tmp/policy-install && chown policy /opt/app/policy /tmp/policy-install
WORKDIR /tmp/policy-install

COPY install-drools.zip apps.zip docker-install.sh do-start.sh wait-for-port.sh ./

RUN unzip install-drools.zip && unzip apps.zip && rm install-drools.zip apps.zip && chown -R policy * && chmod +x *.sh

USER policy
CMD ./do-start.sh
