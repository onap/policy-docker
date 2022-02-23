*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

CommissionAutomationCompositionV1
     [Documentation]  Commission automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session https://${POLICY_RUNTIME_ACM_IP}:6969
     ${postyaml}=  Get file  ${CURDIR}/data/PMSHMultipleCLTosca.yaml
     ${session}=    Create Session      policy  https://${POLICY_RUNTIME_ACM_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   POST On Session     policy  /onap/policy/clamp/acm/v2/commission   data=${postyaml}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

InstantiateAutomationCompositionV1
     [Documentation]  Instantiate automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session https://${POLICY_RUNTIME_ACM_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/InstantiateCL.json
     ${session}=    Create Session      policy  https://${POLICY_RUNTIME_ACM_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   POST On Session     policy  /onap/policy/clamp/acm/v2/instantiation   data=${postjson}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

PassivateAutomationComposition
     [Documentation]  Passivate automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session https://${POLICY_RUNTIME_ACM_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/PassivateCL.json
     ${session}=    Create Session      policy  https://${POLICY_RUNTIME_ACM_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/instantiation/command   data=${postjson}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202

QueryPolicies
     [Documentation]    Runs Policy Participant Query New Policies
     ${auth}=    Create List    policyadmin    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /policy/api/v1/policies     headers=${headers}
     Log    Received response from policy-api {resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

QueryPolicyTypes
     [Documentation]    Runs Policy Participant Query New Policy Types
     ${auth}=    Create List    policyadmin    zb!XztG34
     Log    Creating session https://${POLICY_API_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_API_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /policy/api/v1/policytypes     headers=${headers}
     Log    Received response from policy-api ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

StateChangeRunningAutomationComposition
     [Documentation]  AutomationComposition State Change to RUNNING.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session https://${POLICY_RUNTIME_ACM_IP}:6969
     ${postjson}=  Get file  ${CURDIR}/data/StateChangeRunningCL.json
     ${session}=    Create Session      policy  https://${POLICY_RUNTIME_ACM_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/instantiation/command   data=${postjson}  headers=${headers}  expected_status=406
     Log    Received response from runtime acm ${resp.text}

QueryInstantiatedCLs
     [Documentation]    Get Instantiated AutomationCompositions
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session https://${POLICY_RUNTIME_ACM_IP}:6969
     ${session}=    Create Session      policy  https://${POLICY_RUNTIME_ACM_IP}:6969   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /onap/policy/clamp/acm/v2/instantiation     headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings  ${resp.json()['automationCompositionList'][0]['state']}  UNINITIALISED2PASSIVE
     Should Be Equal As Strings  ${resp.json()['automationCompositionList'][0]['orderedState']}  RUNNING
