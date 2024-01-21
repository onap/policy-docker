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
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      ACM  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     ACM  /onap/policy/clamp/acm/health     headers=${headers}
     Log    Received response from ACM healthcheck {resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

CommissionAutomationComposition
     [Documentation]  Commission automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${postyaml}=  Get file  ${CURDIR}/data/acelement-usecase.yaml
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   POST On Session     policy  /onap/policy/clamp/acm/v2/compositions   data=${postyaml}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${compositionId}  ${respyaml["compositionId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

RegisterParticipants
     [Documentation]  Register Participants.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/participants
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202

PrimeACDefinitions
     [Documentation]  Prime automation composition definition
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}   data=${postjson}  headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  PRIMED


InstantiateAutomationComposition
     [Documentation]  Instantiate automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${K8sEnabled}=    Convert To Boolean    ${CLAMP_K8S_TEST}
     Run Keyword If    '${K8sEnabled}'=='True'    set Suite variable  ${instantiationfile}  AcK8s.json

     ...    ELSE    set Suite variable  ${instantiationfile}  AcDocker.json
     ${postjson}=  Get file  ${CURDIR}/data/${instantiationfile}
     ${updatedpostjson}=   Replace String     ${postjson}     COMPOSITIONIDPLACEHOLDER       ${compositionId}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   POST On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances   data=${updatedpostjson}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${instanceId}    ${respyaml["instanceId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

DeployAutomationComposition
     [Documentation]  Deploy automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}   data=${postjson}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  DEPLOYED


QueryPolicies
     [Documentation]    Verify the new policies deployed
     ${auth}=    Create List    policyadmin    zb!XztG34
     sleep 10
     Log    Creating session http://${POLICY_PAP_IP}
     ${session}=    Create Session      policy  http://${POLICY_PAP_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /policy/pap/v1/policies/deployed     headers=${headers}
     Log    Received response from policy-pap {resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     Dictionary Should Contain Value  ${resp.json()[0]}  onap.policies.native.apex.ac.element


QueryPolicyTypes
     [Documentation]    Verify the new policy types created
     ${auth}=    Create List    policyadmin    zb!XztG34
     sleep  10
     Log    Creating session http://${POLICY_API_IP}}:6969
     ${session}=    Create Session      policy  http://${POLICY_API_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /policy/api/v1/policytypes     headers=${headers}
     Log    Received response from policy-api ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200
     List Should Contain Value  ${resp.json()['policy_types']}  onap.policies.native.Apex


UnDeployAutomationComposition
     [Documentation]  UnDeploy automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}   data=${postjson}   headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  UNDEPLOYED


UnInstantiateAutomationComposition
     [Documentation]  Delete automation composition instance.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}     headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated


DePrimeACDefinitions
     [Documentation]  DePrime automation composition definition
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}   data=${postjson}  headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  COMMISSIONED


DeleteACDefinition
     [Documentation]  Delete automation composition definition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200



*** Keywords ***

VerifyPriming
    [Arguments]  ${primestate}
    [Documentation]    Verify the AC definitions are primed to the participants
    ${auth}=    Create List    runtimeUser    zb!XztG34
    Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
    ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   GET On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['state']}  ${primestate}

VerifyDeployStatus
     [Arguments]  ${deploystate}
     [Documentation]  Verify the Deploy status of automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}     headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     200
     Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['deployState']}  ${deploystate}

VerifyUninstantiated
     [Documentation]  Verify the Uninstantiation of automation composition.
     ${auth}=    Create List    runtimeUser    zb!XztG34
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   GET On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances     headers=${headers}
     Should Be Equal As Strings    ${resp.status_code}     200
     Run Keyword If  ${resp.status_code}==200  Length Should Be  ${resp.json()['automationCompositionList']}  0


