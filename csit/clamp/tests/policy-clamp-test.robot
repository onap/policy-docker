*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

CommissionControlLoopV1
     [Documentation]  Commission control loop.
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969
     ${postyaml}=  Get file  ${CURDIR}/data/PMSHMultipleCLTosca.yaml
     ${session}=    Create Session      policy  http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   POST On Session     policy  /onap/controlloop/v2/commission   data=${postyaml}  headers=${headers}
     Log    Received response from controlloop runtime ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

InstantiateControlLoopV1
     [Documentation]  Instantiate control loop.
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/InstantiateCL.json
     ${session}=    Create Session      policy  http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   POST On Session     policy  /onap/controlloop/v2/instantiation   data=${postjson}  headers=${headers}
     Log    Received response from controlloop runtime ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

PassivateControlLoop
     [Documentation]  Passivate control loop.
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/PassivateCL.json
     ${session}=    Create Session      policy  http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/controlloop/v2/instantiation/command   data=${postjson}  headers=${headers}
     Log    Received response from controlloop runtime ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202

QueryPolicies
     [Documentation]    Runs Policy Participant Query New Policies
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  http://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /policy/api/v1/policies     headers=${headers}
     Log    Received response from policy-api {resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

QueryPolicyTypes
     [Documentation]    Runs Policy Participant Query New Policy Types
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  http://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /policy/api/v1/policytypes     headers=${headers}
     Log    Received response from policy-api ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

StateChangeRunningControlLoop
     [Documentation]  ControlLoop State Change to RUNNING.
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/StateChangeRunningCL.json
     ${session}=    Create Session      policy  http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/controlloop/v2/instantiation/command   data=${postjson}  headers=${headers}  expected_status=406
     Log    Received response from controlloop runtime ${resp.text}

QueryInstantiatedCLs
     [Documentation]    Get Instantiated ControlLoops
     ${auth}=    Create List    healthcheck    zb!XztG34
     Log    Creating session http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969
     ${session}=    Create Session      policy  http://${POLICY_CONTROLLOOP_RUNTIME_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /onap/controlloop/v2/instantiation     headers=${headers}
     Log    Received response from controlloop runtime ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings  ${resp.json()['controlLoopList'][0]['state']}  UNINITIALISED2PASSIVE
     Should Be Equal As Strings  ${resp.json()['controlLoopList'][0]['orderedState']}  RUNNING
