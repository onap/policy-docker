FROM python:3
ARG CSIT_SCRIPT=${CSIT_SCRIPT}
ARG ROBOT_FILE=${ROBOT_FILE}
ENV ROBOT_WORKSPACE /opt/robotworkspace
ENV ROBOT_FILE $ROBOT_FILE
RUN python3 -m pip install --upgrade pip
RUN python3 -m pip install --upgrade --extra-index-url="https://nexus3.onap.org/repository/PyPi.staging/simple" 'robotframework-onap==0.5.1.*' --pre
RUN python3 -m pip freeze
RUN mkdir -p ${ROBOT_WORKSPACE}
COPY ${CSIT_SCRIPT} ${ROBOT_WORKSPACE}
COPY tests/ ${ROBOT_WORKSPACE}/
WORKDIR ${ROBOT_WORKSPACE}
RUN chmod +x run-test.sh
CMD ["sh", "-c", "./run-test.sh" , "${ROBOT_FILE}"]
