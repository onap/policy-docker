FROM onap/policy/policy-base

RUN pip install http-prompt
RUN mkdir -p /opt/app/policy/opt /tmp/policy-install && \
    chown -R policy /opt/app/policy /tmp/policy-install

WORKDIR /tmp/policy-install

COPY install-drools.zip apps.zip docker-install.sh do-start.sh wait-for-port.sh ./
ADD http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.2.0/flyway-commandline-4.2.0.tar.gz /opt/app/policy/opt

RUN unzip install-drools.zip && \
    unzip apps.zip && \
    rm install-drools.zip apps.zip && \
    chown -R policy * && \
    chmod +x *.sh && \
    ln -s /opt/app/policy/opt/flyway-4.2.0 /opt/app/policy/opt/flyway && \
    ln -s /opt/app/policy/opt/flyway/flyway /opt/app/policy/bin/

USER policy
CMD ./do-start.sh
