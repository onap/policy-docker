*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     String
Library     json
Library     yaml

*** Test Cases ***
Healthcheck
     [Documentation]    Healthcheck on Clamp Acm
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://localhost:${POLICY_RUNTIME_ACM_PORT}
     ${session}=    Create Session      ACM  http://localhost:${POLICY_RUNTIME_ACM_PORT}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     ACM  /onap/policy/clamp/acm/health     headers=${headers}
     Log    Received response from ACM healthcheck {resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

#CommissionAutomationCompositionV1
#     [Documentation]  Commission automation composition.
#     ${auth}=    Create List    runtimeUser    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_RUNTIME_ACM_PORT}
#     ${postyaml}=  Get file  ${CURDIR}/data/functional-pmsh-usecase.yaml
#     ${session}=    Create Session      policy  http://localhost:${POLICY_RUNTIME_ACM_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
#     ${resp}=   POST On Session     policy  /onap/policy/clamp/acm/v2/compositions   data=${postyaml}  headers=${headers}
#     Log    Received response from runtime acm ${resp.text}
#     ${respyaml}=  yaml.Safe Load  ${resp.text}
#     set Suite variable  ${compositionId}  ${respyaml["compositionId"]}
#     Should Be Equal As Strings    ${resp.status_code}     201
#
#InstantiateAutomationCompositionV1
#     [Documentation]  Instantiate automation composition.
#     ${auth}=    Create List    runtimeUser    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_RUNTIME_ACM_PORT}
#     ${postjson}=  Get file  ${CURDIR}/data/AutomationComposition.json
#     ${updatedpostjson}=   Replace String     ${postjson}     COMPOSITIONIDPLACEHOLDER       ${compositionId}
#     ${session}=    Create Session      policy  http://localhost:${POLICY_RUNTIME_ACM_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
#     ${resp}=   POST On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances   data=${updatedpostjson}  headers=${headers}
#     Log    Received response from runtime acm ${resp.text}
#     ${respyaml}=  yaml.Safe Load  ${resp.text}
#     set Suite variable  ${instanceId}    ${respyaml["instanceId"]}
#     Should Be Equal As Strings    ${resp.status_code}     201
#
#PassivateAutomationComposition
#     [Documentation]  Passivate automation composition.
#     ${auth}=    Create List    runtimeUser    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_RUNTIME_ACM_PORT}
#     ${postjson}=  Get file  ${CURDIR}/data/PassiveCommand.json
#     ${session}=    Create Session      policy  http://localhost:${POLICY_RUNTIME_ACM_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
#     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}   data=${postjson}  headers=${headers}
#     Log    Received response from runtime acm ${resp.text}
#     Should Be Equal As Strings    ${resp.status_code}     200
#
#QueryPolicies
#     [Documentation]    Runs Policy Participant Query New Policies
#     ${auth}=    Create List    policyadmin    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_API_PORT}
#     ${session}=    Create Session      policy  http://localhost:${POLICY_API_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
#     ${resp}=   GET On Session     policy  /policy/api/v1/policies     headers=${headers}
#     Log    Received response from policy-api {resp.text}
#     Should Be Equal As Strings    ${resp.status_code}     200
#
#QueryPolicyTypes
#     [Documentation]    Runs Policy Participant Query New Policy Types
#     ${auth}=    Create List    policyadmin    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_API_PORT}}:6969
#     ${session}=    Create Session      policy  http://localhost:${POLICY_API_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
#     ${resp}=   GET On Session     policy  /policy/api/v1/policytypes     headers=${headers}
#     Log    Received response from policy-api ${resp.text}
#     Should Be Equal As Strings    ${resp.status_code}     200
#
#StateChangeRunningAutomationComposition
#     [Documentation]  AutomationComposition State Change to RUNNING.
#     ${auth}=    Create List    runtimeUser    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_RUNTIME_ACM_PORT}
#     ${postjson}=  Get file  ${CURDIR}/data/RunningCommand.json
#     ${session}=    Create Session      policy  http://localhost:${POLICY_RUNTIME_ACM_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
#     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}   data=${postjson}  headers=${headers}  expected_status=400
#     Log    Received response from runtime acm ${resp.text}
#
#QueryInstantiatedACs
#     [Documentation]    Get Instantiated AutomationCompositions
#     ${auth}=    Create List    runtimeUser    zb!XztG34
#     Log    Creating session http://localhost:${POLICY_RUNTIME_ACM_PORT}
#     ${session}=    Create Session      policy  http://localhost:${POLICY_RUNTIME_ACM_PORT}   auth=${auth}
#     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
#     ${resp}=   GET On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}     headers=${headers}
#     Log    Received response from runtime acm ${resp.text}
#     Should Be Equal As Strings    ${resp.status_code}     200
#     Should Be Equal As Strings  ${resp.json()['state']}  UNINITIALISED2PASSIVE
#     Should Be Equal As Strings  ${resp.json()['orderedState']}  PASSIVE
