FROM ecomp-nexus:51220/policy/policy-os


# note that in following command sequence, wget exit status is 1 even on success,
# so can't use && for conditional execution of next command
RUN \
    cd /tmp && \
    wget https://sonatype-download.global.ssl.fastly.net/nexus/oss/nexus-2.14.2-01-bundle.tar.gz ; \
    mkdir /opt/nexus && cd /opt/nexus && \
    tar xfz /tmp/nexus-2.14.2-01-bundle.tar.gz && \
    useradd --create-home --shell /bin/bash nexus && \
    chown -R nexus *

# make the sonatype-work directory persistent
VOLUME /opt/nexus/sonatype-work

USER nexus
CMD bash -c "/opt/nexus/nexus-2.14.2-01/bin/nexus start && sleep 1000d"

