FROM python:3-slim-bullseye
ARG CSIT_SCRIPT=${CSIT_SCRIPT}
ARG ROBOT_FILE=${ROBOT_FILE}
ENV ROBOT_WORKSPACE=/opt/robotworkspace ROBOT_FILE=$ROBOT_FILE
RUN python3 -m pip install --upgrade pip && \
    python3 -m pip install --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==0.6.0.*' --pre && \
    python3 -m pip freeze
RUN mkdir -p ${ROBOT_WORKSPACE}
COPY ${CSIT_SCRIPT} tests/ ${ROBOT_WORKSPACE}/
WORKDIR ${ROBOT_WORKSPACE}
CMD ["sh", "-c", "./run-test.sh" , "${ROBOT_FILE}"]
