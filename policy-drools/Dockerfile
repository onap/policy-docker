FROM onap/policy/policy-base

RUN pip install http-prompt
RUN mkdir -p /opt/app/policy/opt /tmp/policy-install && \
    chown -R policy /opt/app/policy /tmp/policy-install

WORKDIR /tmp/policy-install

COPY install-drools.zip apps.zip docker-install.sh do-start.sh wait-for-port.sh ./

RUN unzip install-drools.zip && \
    unzip apps.zip && \
    rm install-drools.zip apps.zip && \
    chown -R policy * && \
    chmod +x *.sh && \
    wget http://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/4.2.0/flyway-commandline-4.2.0.tar.gz && \
    tar -C /opt/app -xzf flyway-commandline-4.2.0.tar.gz && \
    chmod +x /opt/app/flyway-4.2.0/flyway && \
    ln -f -s /opt/app/flyway-4.2.0 /opt/app/flyway && \
    ln -f -s /opt/app/flyway/flyway /usr/local/bin

USER policy
CMD ./do-start.sh
