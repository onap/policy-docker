#! /bin/bash

${POLICY_HOME}/bin/features enable healthcheck

sed -i -e 's/DCAE-CL-EVENT/unauthenticated.TCA_EVENT_OUTPUT/' \
       -e '/TCA_EVENT_OUTPUT\.servers/s/servers=.*$/servers=10.0.4.102/' \
    $POLICY_HOME/config/v*-controller.properties
