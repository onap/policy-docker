*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     String
Library     json
Library     yaml
Resource    common-library.robot

*** Test Cases ***
HealthcheckAcm
    [Documentation]    Healthcheck on Clamp Acm
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  onap/policy/clamp/acm/health  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200

HealthcheckParticipantSim
    [Documentation]    Healthcheck on Participant Simulator
    ${auth}=    ParticipantAuth
    ${resp}=    MakeGetRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/health  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200

HealthcheckApi
    [Documentation]    Healthcheck on policy-api
    Wait Until Keyword Succeeds    5 min    10 sec    VerifyHealthcheckApi

HealthcheckPap
    [Documentation]    Healthcheck on policy-pap
    Wait Until Keyword Succeeds    5 min    10 sec    VerifyHealthcheckPap

RegisterParticipants
    [Documentation]  Register Participants.
    ${auth}=    ClampAuth
    Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
    ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
    ${resp}=   PUT On Session     policy  /onap/policy/clamp/acm/v2/participants
    Log    Received response from runtime acm ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     202

CommissionAcDefinitionTimeout
    [Documentation]  Commission automation composition definition Timeout.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-definition-timeout.yaml
    ${tmpCompositionId}=  MakeCommissionAcDefinition  ${postyaml}
    set Suite variable  ${compositionTimeoutId}  ${tmpCompositionId}

TimeoutPrimeACDefinition
    [Documentation]  Prime automation composition definition Timeout.
    SetParticipantSimTimeout
    ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
    PrimeACDefinition  ${postjson}  ${compositionTimeoutId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResultPriming  ${compositionTimeoutId}   TIMEOUT

DeleteACDefinitionTimeout
    [Documentation]  DePrime and Delete automation composition definition Timeout.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
    PrimeACDefinition  ${postjson}  ${compositionTimeoutId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionTimeoutId}  COMMISSIONED
    DeleteACDefinition  ${compositionTimeoutId}

CommissionAutomationCompositionSimple
    [Documentation]  Commission simple automation composition definition.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-definition-simple.yaml
    ${tmpCompositionId}=  MakeCommissionAcDefinition  ${postyaml}
    set Suite variable  ${simpleCompositionId}  ${tmpCompositionId}

PrimeACDefinitionsSimple
    [Documentation]  Prime simple automation composition definition
    ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
    PrimeACDefinition  ${postjson}  ${simpleCompositionId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${simpleCompositionId}  PRIMED

InstantiateAutomationCompositionSimple
    [Documentation]  Instantiate simple automation composition.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-simple.yaml
    ${tmpInstanceId}=  MakeYamlInstantiateAutomationComposition   ${simpleCompositionId}   ${postyaml}
    set Suite variable  ${simpleInstanceId}    ${tmpInstanceId}

FailDeployAutomationCompositionSimple
    [Documentation]  Fail Simple Deploy automation composition.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
    ChangeStatusAutomationComposition  ${simpleCompositionId}   ${simpleInstanceId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${simpleCompositionId}  ${simpleInstanceId}  FAILED

UnDeployAutomationCompositionSimple
    [Documentation]  UnDeploy simple automation composition.
    SetParticipantSimDelay
    ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
    ChangeStatusAutomationComposition  ${simpleCompositionId}   ${simpleInstanceId}  ${postjson}
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyDeployStatus  ${simpleCompositionId}  ${simpleInstanceId}  UNDEPLOYING
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyInternalStateElementsRuntime  ${simpleCompositionId}   ${simpleInstanceId}  UNDEPLOYING
    Wait Until Keyword Succeeds    3 min    5 sec    VerifyDeployStatus  ${simpleCompositionId}  ${simpleInstanceId}  UNDEPLOYED
    VerifyInternalStateElementsRuntime  ${simpleCompositionId}   ${simpleInstanceId}  UNDEPLOYED

UnInstantiateAutomationCompositionSimple
    [Documentation]  Delete simple automation composition instance.
    SetParticipantSimSuccess
    DeleteAutomationComposition  ${simpleCompositionId}  ${simpleInstanceId}
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${simpleCompositionId}

DePrimeACDefinitionSimple
    [Documentation]  DePrime simple automation composition definition
    ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
    PrimeACDefinition  ${postjson}  ${simpleCompositionId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${simpleCompositionId}  COMMISSIONED

CommissionAutomationComposition
    [Documentation]  Commission automation composition definition.
    ${postyaml}=  Get file  ${CURDIR}/data/acelement-usecase.yaml
    ${tmpCompositionId}=  MakeCommissionAcDefinition  ${postyaml}
    set Suite variable  ${compositionId}  ${tmpCompositionId}

CommissionAcDefinitionMigrationFrom
    [Documentation]  Commission automation composition definition From.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-definition-migration-from.yaml
    ${tmpCompositionId}=  MakeCommissionAcDefinition  ${postyaml}
    set Suite variable  ${compositionFromId}  ${tmpCompositionId}

CommissionAcDefinitionMigrationTo
    [Documentation]  Commission automation composition definition To.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-definition-migration-to.yaml
    ${tmpCompositionId}=  MakeCommissionAcDefinition  ${postyaml}
    set Suite variable  ${compositionToId}  ${tmpCompositionId}

PrimeACDefinitions
    [Documentation]  Prime automation composition definition
    ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
    PrimeACDefinition  ${postjson}  ${compositionId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionId}  PRIMED

FailPrimeACDefinitionFrom
    [Documentation]  Prime automation composition definition Migration From with Fail.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
    PrimeACDefinition  ${postjson}  ${compositionFromId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResultPriming  ${compositionFromId}   FAILED

PrimeACDefinitionFrom
    [Documentation]  Prime automation composition definition Migration From.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
    PrimeACDefinition  ${postjson}  ${compositionFromId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionFromId}  PRIMED

PrimeACDefinitionTo
    [Documentation]  Prime automation composition definition Migration To.
    ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
    PrimeACDefinition  ${postjson}  ${compositionToId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionToId}  PRIMED

DeleteUndeployedInstantiateAutomationComposition
    [Documentation]  Delete Instantiate automation composition that has never been deployed.
    Run Keyword If    '${TEST_ENV}'=='k8s'    set Suite variable  ${instantiationfile}  AcK8s.json

    ...    ELSE    set Suite variable  ${instantiationfile}  AcDocker.json
    ${postjson}=  Get file  ${CURDIR}/data/${instantiationfile}
    ${tmpInstanceId}=  MakeJsonInstantiateAutomationComposition  ${compositionId}  ${postjson}
    DeleteAutomationComposition  ${compositionId}  ${tmpInstanceId}
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${compositionId}

InstantiateAutomationComposition
    [Documentation]  Instantiate automation composition.
    Run Keyword If    '${TEST_ENV}'=='k8s'    set Suite variable  ${instantiationfile}  AcK8s.json

    ...    ELSE    set Suite variable  ${instantiationfile}  AcDocker.json
    ${postjson}=  Get file  ${CURDIR}/data/${instantiationfile}
    ${tmpInstanceId}=  MakeJsonInstantiateAutomationComposition  ${compositionId}  ${postjson}
    Set Suite Variable  ${instanceId}  ${tmpInstanceId}

InstantiateAutomationCompositionTimeout
    [Documentation]  Instantiate automation composition timeout.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-timeout.yaml
    ${tmpInstanceId}=  MakeYamlInstantiateAutomationComposition   ${compositionFromId}   ${postyaml}
    set Suite variable  ${instanceTimeoutId}    ${tmpInstanceId}

DeployAutomationCompositionTimeout
    [Documentation]  Deploy automation composition timeout.
    SetParticipantSimTimeout
    ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
    ChangeStatusAutomationComposition  ${compositionFromId}  ${instanceTimeoutId}   ${postjson}
    Wait Until Keyword Succeeds    5 min    5 sec    VerifyStateChangeResult  ${compositionFromId}  ${instanceTimeoutId}  TIMEOUT

DeleteAutomationCompositionTimeout
    [Documentation]  Delete automation composition timeout.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
    ChangeStatusAutomationComposition  ${compositionFromId}  ${instanceTimeoutId}  ${postjson}
    Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  ${compositionFromId}  ${instanceTimeoutId}  UNDEPLOYED
    DeleteAutomationComposition  ${compositionFromId}  ${instanceTimeoutId}
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${compositionFromId}

InstantiateAutomationCompositionMigrationFrom
    [Documentation]  Instantiate automation composition migration.
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-migration-from.yaml
    ${tmpInstanceId}=  MakeYamlInstantiateAutomationComposition   ${compositionFromId}   ${postyaml}
    set Suite variable  ${instanceMigrationId}    ${tmpInstanceId}

FailPrepareAutomationCompositionMigrationFrom
    [Documentation]  Fail Prepare automation composition migration.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/PrepareAC.json
    ChangeStatusAutomationComposition   ${compositionFromId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${compositionFromId}  ${instanceMigrationId}  FAILED

PrepareAutomationCompositionMigrationFrom
    [Documentation]  Prepare automation composition migration.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/PrepareAC.json
    ChangeStatusAutomationComposition   ${compositionFromId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    10 min    5 sec    VerifySubStatus  ${compositionFromId}  ${instanceMigrationId}
    VerifyPrepareElementsRuntime   ${compositionFromId}  ${instanceMigrationId}

FailDeployAutomationCompositionMigration
    [Documentation]  Fail Deploy automation composition.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
    ChangeStatusAutomationComposition  ${compositionFromId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${compositionFromId}  ${instanceMigrationId}  FAILED

DeployAutomationComposition
    [Documentation]  Deploy automation composition.
    ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
    ChangeStatusAutomationComposition  ${compositionId}  ${instanceId}  ${postjson}
    Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  ${compositionId}  ${instanceId}  DEPLOYED

CheckTraces
    [Documentation]    Verify that traces are being recorded in jaeger
    Log    Verifying Jaeger traces
    ${acmResp}=    VerifyTracingWorks    ${JAEGER_IP}    acm-r
    ${httpResp}=    VerifyTracingWorks    ${JAEGER_IP}    http-ppnt
    ${policyResp}=    VerifyTracingWorks    ${JAEGER_IP}    policy-ppnt
    ${k8sResp}=    VerifyTracingWorks    ${JAEGER_IP}    k8s-ppnt
    Should Not Be Empty    ${acmResp.json()["data"][0]["spans"][0]["spanID"]}
    Log  Received spanID is ${acmResp.json()["data"][0]["spans"][0]["spanID"]}
    Should Not Be Empty    ${httpResp.json()["data"][0]["spans"][0]["spanID"]}
    Should Not Be Empty    ${policyResp.json()["data"][0]["spans"][0]["spanID"]}
    Should Not Be Empty    ${k8sResp.json()["data"][0]["spans"][0]["spanID"]}

CheckKafkaPresentInTraces
    [Documentation]    Verify that kafka traces are being recorded in jaeger
    Log    Verifying Kafka Jaeger traces
    ${acmResp}=    VerifyKafkaInTraces    ${JAEGER_IP}    acm-r
    ${httpResp}=    VerifyKafkaInTraces    ${JAEGER_IP}    http-ppnt
    ${policyResp}=    VerifyKafkaInTraces    ${JAEGER_IP}    policy-ppnt
    ${k8sResp}=    VerifyKafkaInTraces    ${JAEGER_IP}    k8s-ppnt
    Should Not Be Empty    ${acmResp.json()["data"][0]["spans"][0]["spanID"]}
    Log  Received spanID is ${acmResp.json()["data"][0]["spans"][0]["spanID"]}
    Should Not Be Empty    ${httpResp.json()["data"][0]["spans"][0]["spanID"]}
    Should Not Be Empty    ${policyResp.json()["data"][0]["spans"][0]["spanID"]}
    Should Not Be Empty    ${k8sResp.json()["data"][0]["spans"][0]["spanID"]}

CheckHttpPresentInAcmTraces
    [Documentation]    Verify that http traces are being recorded in jaeger
    Log    Verifying Http Jaeger traces
    ${acmResp}=    VerifyHttpInTraces    ${JAEGER_IP}    acm-r
    Should Not Be Empty    ${acmResp.json()["data"][0]["spans"][0]["spanID"]}
    Log  Received spanID is ${acmResp.json()["data"][0]["spans"][0]["spanID"]}

QueryPolicies
    [Documentation]    Verify the new policies deployed
    ${auth}=    PolicyAdminAuth
    Sleep  10s
    Log    Creating session http://${POLICY_PAP_IP}
    ${session}=    Create Session      policy  http://${POLICY_PAP_IP}   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   GET On Session     policy  /policy/pap/v1/policies/deployed     headers=${headers}
    Log    Received response from policy-pap {resp.text}
    Should Be Equal As Strings    ${resp.status_code}     200
    Dictionary Should Contain Value  ${resp.json()[0]}  onap.policies.native.apex.ac.element

QueryPolicyTypes
    [Documentation]    Verify the new policy types created
    ${auth}=    PolicyAdminAuth
    Sleep  10s
    Log    Creating session http://${POLICY_API_IP}:6969
    ${session}=    Create Session      policy  http://${POLICY_API_IP}   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   GET On Session     policy  /policy/api/v1/policytypes     headers=${headers}
    Log    Received response from policy-api ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     200
    List Should Contain Value  ${resp.json()['policy_types']}  onap.policies.native.Apex

DeployAutomationCompositionMigration
    [Documentation]  Deploy automation composition.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
    ChangeStatusAutomationComposition  ${compositionFromId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionFromId}  ${instanceMigrationId}  DEPLOYED

SendOutPropertiesToRuntime
    [Documentation]  Send Out Properties To Runtime
    ${auth}=    ParticipantAuth
    ${postjson}=  Get file  ${CURDIR}/data/OutProperties.json
    ${updatedpostjson}=   Replace String     ${postjson}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
    ${updatedpostjson}=   Replace String     ${updatedpostjson}     TEXTPLACEHOLDER       DumpTest
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/datas  ${updatedpostjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/datas  ${updatedpostjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${updatedpostjson}=   Replace String     ${postjson}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
    ${updatedpostjson}=   Replace String     ${updatedpostjson}     TEXTPLACEHOLDER       MyTextToSend
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/datas  ${updatedpostjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPropertiesUpdated  ${compositionFromId}  ${instanceMigrationId}  MyTextToSend

FailReviewAutomationCompositionMigrationFrom
    [Documentation]  Fail Review automation composition migration.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/ReviewAC.json
    ChangeStatusAutomationComposition  ${compositionFromId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${compositionFromId}  ${instanceMigrationId}  FAILED

ReviewAutomationCompositionMigrationFrom
    [Documentation]  Review automation composition migration.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/ReviewAC.json
    ChangeStatusAutomationComposition  ${compositionFromId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    10 min    5 sec    VerifySubStatus  ${compositionFromId}  ${instanceMigrationId}

AutomationCompositionUpdate
    [Documentation]  Update of an automation composition.
    ${auth}=    ClampAuth
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-update.yaml
    ${updatedpostyaml}=   Replace String     ${postyaml}     COMPOSITIONIDPLACEHOLDER       ${compositionFromId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     TEXTPLACEHOLDER       MyTextUpdated
    ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}/instances  ${updatedpostyaml}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionFromId}  ${instanceMigrationId}  DEPLOYED
    VerifyPropertiesUpdated  ${compositionFromId}  ${instanceMigrationId}  MyTextUpdated
    VerifyParticipantSim  ${instanceMigrationId}  MyTextUpdated

PrecheckAutomationCompositionMigration
    [Documentation]  Precheck Migration of an automation composition.
    ${auth}=    ClampAuth
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-precheck-migration.yaml
    ${updatedpostyaml}=   Replace String     ${postyaml}     COMPOSITIONIDPLACEHOLDER       ${compositionFromId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     COMPOSITIONTARGETIDPLACEHOLDER       ${compositionToId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     TEXTPLACEHOLDER       TextForMigration
    ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}/instances  ${updatedpostyaml}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Wait Until Keyword Succeeds    2 min    5 sec    VerifySubStatus  ${compositionFromId}  ${instanceMigrationId}

AutomationCompositionMigrationTo
    [Documentation]  Migration of an automation composition.
    ${auth}=    ClampAuth
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-migration-to.yaml
    ${updatedpostyaml}=   Replace String     ${postyaml}     COMPOSITIONIDPLACEHOLDER       ${compositionFromId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     COMPOSITIONTARGETIDPLACEHOLDER       ${compositionToId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     TEXTPLACEHOLDER       TextForMigration
    ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}/instances  ${updatedpostyaml}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionToId}  ${instanceMigrationId}  DEPLOYED
    VerifyPropertiesUpdated  ${compositionToId}  ${instanceMigrationId}  TextForMigration
    VerifyParticipantSim  ${instanceMigrationId}  TextForMigration
    VerifyMigratedElementsRuntime  ${compositionToId}  ${instanceMigrationId}
    VerifyMigratedElementsSim  ${instanceMigrationId}

FailAutomationCompositionMigration
    [Documentation]  Fail Migration of an automation composition.
    SetParticipantSimFail
    ${auth}=    ClampAuth
    ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-migration-fail.yaml
    ${updatedpostyaml}=   Replace String     ${postyaml}     COMPOSITIONIDPLACEHOLDER       ${compositionToId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     COMPOSITIONTARGETIDPLACEHOLDER       ${compositionFromId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
    ${updatedpostyaml}=   Replace String     ${updatedpostyaml}     TEXTPLACEHOLDER       TextForMigration
    ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionToId}/instances  ${updatedpostyaml}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${compositionToId}  ${instanceMigrationId}  FAILED

FailDePrimeACDefinitionsFrom
    [Documentation]  Fail DePrime automation composition definition migration From.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
    PrimeACDefinition  ${postjson}  ${compositionFromId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResultPriming  ${compositionFromId}   FAILED

DePrimeACDefinitionsFrom
    [Documentation]  DePrime automation composition definition migration From.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
    PrimeACDefinition  ${postjson}  ${compositionFromId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionFromId}  COMMISSIONED

UnDeployAutomationComposition
    [Documentation]  UnDeploy automation composition.
    ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
    ChangeStatusAutomationComposition  ${compositionId}   ${instanceId}  ${postjson}
    Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  ${compositionId}  ${instanceId}  UNDEPLOYED

FailUnDeployAutomationCompositionMigrationTo
    [Documentation]  Fail UnDeploy automation composition migrated.
    SetParticipantSimFail
    ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
    ChangeStatusAutomationComposition  ${compositionToId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${compositionToId}  ${instanceMigrationId}  FAILED

UnDeployAutomationCompositionMigrationTo
    [Documentation]  UnDeploy automation composition migrated.
    SetParticipantSimSuccess
    ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
    ChangeStatusAutomationComposition  ${compositionToId}   ${instanceMigrationId}  ${postjson}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionToId}  ${instanceMigrationId}  UNDEPLOYED

UnInstantiateAutomationComposition
    [Documentation]  Delete automation composition instance.
    DeleteAutomationComposition  ${compositionId}  ${instanceId}
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${compositionId}

FailUnInstantiateAutomationCompositionMigrationTo
    [Documentation]  Fail Delete automation composition instance migrated.
    SetParticipantSimFail
    DeleteAutomationComposition  ${compositionToId}  ${instanceMigrationId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyStateChangeResult  ${compositionToId}  ${instanceMigrationId}  FAILED

UnInstantiateAutomationCompositionMigrationTo
    [Documentation]  Delete automation composition instance migrated.
    SetParticipantSimSuccess
    DeleteAutomationComposition  ${compositionToId}  ${instanceMigrationId}
    Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${compositionToId}

DePrimeACDefinitions
    [Documentation]  DePrime automation composition definition
    ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
    PrimeACDefinition  ${postjson}  ${compositionId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionId}  COMMISSIONED

DePrimeACDefinitionsTo
    [Documentation]  DePrime automation composition definition migration To.
    ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
    PrimeACDefinition  ${postjson}  ${compositionToId}
    Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionToId}  COMMISSIONED

DeleteACDefinitions
    [Documentation]  Delete automation composition definition.
    DeleteACDefinition  ${compositionId}

DeleteACDefinitionFrom
    [Documentation]  Delete automation composition definition migration From.
    DeleteACDefinition  ${compositionFromId}

DeleteACDefinitionTo
    [Documentation]  Delete automation composition definition migration To.
    DeleteACDefinition  ${compositionToId}

*** Keywords ***

VerifyHealthcheckApi
    [Documentation]    Verify Healthcheck on policy-api
    ${auth}=    PolicyAdminAuth
    ${resp}=    MakeGetRequest  policy  ${POLICY_API_IP}  /policy/api/v1/health  ${auth}
    Should Be Equal As Strings    ${resp.status_code}   200

VerifyHealthcheckPap
    [Documentation]    Verify Healthcheck on policy-pap
    ${auth}=    PolicyAdminAuth
    ${resp}=    MakeGetRequest  policy  ${POLICY_PAP_IP}  /policy/pap/v1/health  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200

VerifyPriming
    [Arguments]  ${theCompositionId}  ${primestate}
    [Documentation]    Verify the AC definitions are primed to the participants
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}   200
    Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  NO_ERROR
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['state']}  ${primestate}

VerifyStateChangeResultPriming
    [Arguments]  ${theCompositionId}  ${stateChangeResult}
    [Documentation]    Verify the AC definitions are primed to the participants
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  ${stateChangeResult}

VerifyDeployStatus
    [Arguments]  ${theCompositionId}  ${theInstanceId}  ${deploystate}
    [Documentation]  Verify the Deploy status of automation composition.
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  NO_ERROR
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['deployState']}  ${deploystate}

VerifySubStatus
    [Arguments]  ${theCompositionId}  ${theInstanceId}
    [Documentation]  Verify the Sub status of automation composition.
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  NO_ERROR
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['subState']}  NONE

VerifyStateChangeResult
    [Arguments]  ${theCompositionId}  ${theInstanceId}  ${stateChangeResult}
    [Documentation]  Verify the Deploy status of automation composition.
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  ${stateChangeResult}

VerifyPropertiesUpdated
    [Arguments]  ${theCompositionId}  ${theInstanceId}  ${textToFind}
    [Documentation]  Verify the Deploy status of automation composition.
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${respstring}   Convert To String   ${resp.json()}
    Run Keyword If  ${resp.status_code}==200  Should Match Regexp  ${respstring}  ${textToFind}

VerifyInternalStateElementsRuntime
    [Arguments]  ${theCompositionId}  ${theInstanceId}  ${deploystate}
    [Documentation]  Verify the Instance elements during operation
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Should Be Equal As Strings  ${resp.json()['deployState']}   ${deploystate}
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb80c6c34']['outProperties']['InternalState']}
    Should Be Equal As Strings  ${respstring}  ${deploystate}

VerifyMigratedElementsRuntime
    [Arguments]  ${theCompositionId}  ${theInstanceId}
    [Documentation]  Verify the Instance elements after Migration
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${respstring}   Convert To String   ${resp.json()}
    Should Match Regexp  ${respstring}  Sim_NewAutomationCompositionElement
    Should Not Match Regexp  ${respstring}  Sim_SinkAutomationCompositionElement
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb79c6c34']['outProperties']['stage']}
    Should Be Equal As Strings  ${respstring}  [1, 2]
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb79c6c35']['outProperties']['stage']}
    Should Be Equal As Strings  ${respstring}  [0, 1]
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb79c6c37']['outProperties']['stage']}
    Should Be Equal As Strings  ${respstring}  [0, 2]

VerifyPrepareElementsRuntime
    [Arguments]  ${theCompositionId}  ${theInstanceId}
    [Documentation]  Verify the Instance elements after Prepare
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb79c6c34']['outProperties']['prepareStage']}
    Should Be Equal As Strings  ${respstring}  [1, 2]
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb79c6c35']['outProperties']['prepareStage']}
    Should Be Equal As Strings  ${respstring}  [0, 1]
    ${respstring}   Convert To String   ${resp.json()['elements']['709c62b3-8918-41b9-a747-d21eb79c6c36']['outProperties']['prepareStage']}
    Should Be Equal As Strings  ${respstring}  [0, 2]

VerifyMigratedElementsSim
    [Arguments]  ${theInstanceId}
    [Documentation]  Query on Participant Simulator
    ${auth}=    ParticipantAuth
    ${resp}=    MakeGetRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${respstring}   Convert To String   ${resp.json()}
    Should Match Regexp  ${respstring}  Sim_NewAutomationCompositionElement
    Should Not Match Regexp  ${respstring}  Sim_SinkAutomationCompositionElement

VerifyParticipantSim
    [Arguments]  ${theInstanceId}  ${textToFind}
    [Documentation]  Query on Participant Simulator
    ${auth}=    ParticipantAuth
    ${resp}=    MakeGetRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/instances/${theInstanceId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    ${respstring}   Convert To String   ${resp.json()}
    Should Match Regexp  ${respstring}  ${textToFind}

VerifyUninstantiated
    [Arguments]  ${theCompositionId}
    [Documentation]  Verify the Uninstantiation of automation composition.
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}   /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200
    Run Keyword If  ${resp.status_code}==200  Length Should Be  ${resp.json()['automationCompositionList']}  0

SetParticipantSimFail
    [Documentation]  Set Participant Simulator Fail.
    ${auth}=    ParticipantAuth
    ${postjson}=  Get file  ${CURDIR}/data/SettingSimPropertiesFail.json
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/parameters  ${postjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200

SetParticipantSimSuccess
    [Documentation]  Set Participant Simulator Success.
    ${auth}=    ParticipantAuth
    ${postjson}=  Get file  ${CURDIR}/data/SettingSimPropertiesSuccess.json
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/parameters  ${postjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200

SetParticipantSimTimeout
    [Documentation]  Set Participant Simulator Timeout.
    ${auth}=    ParticipantAuth
    ${postjson}=  Get file  ${CURDIR}/data/SettingSimPropertiesTimeout.json
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/parameters  ${postjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200

SetParticipantSimDelay
    [Documentation]  Set Participant Simulator Delay.
    ${auth}=    ParticipantAuth
    ${postjson}=  Get file  ${CURDIR}/data/SettingSimPropertiesDelay.json
    ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/parameters  ${postjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     200


ClampAuth
    ${auth}=    Create List    runtimeUser    zb!XztG34
    RETURN  ${auth}

ParticipantAuth
    ${auth}=    Create List    participantUser    zb!XztG34
    RETURN  ${auth}

MakeCommissionAcDefinition
    [Arguments]   ${postyaml}
    ${auth}=    ClampAuth
    ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions  ${postyaml}  ${auth}
    ${respyaml}=  yaml.Safe Load  ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     201
    RETURN  ${respyaml["compositionId"]}

PrimeACDefinition
    [Arguments]   ${postjson}  ${compositionId}
    ${auth}=    ClampAuth
    ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}  ${postjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     202

DeleteACDefinition
    [Arguments]   ${compositionId}
    ${auth}=    ClampAuth
    Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
    ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
    ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}  headers=${headers}
    Log    Received response from runtime acm ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     200

MakeJsonInstantiateAutomationComposition
    [Arguments]  ${compositionId}  ${postjson}
    ${auth}=    ClampAuth
    ${updatedpostjson}=   Replace String     ${postjson}     COMPOSITIONIDPLACEHOLDER       ${compositionId}
    ${resp}=   MakeJsonPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances  ${updatedpostjson}  ${auth}
    ${respyaml}=  yaml.Safe Load  ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     201
    RETURN  ${respyaml["instanceId"]}

MakeYamlInstantiateAutomationComposition
    [Arguments]  ${compositionId}  ${postyaml}
    ${auth}=    ClampAuth
    ${updatedpostyaml}=   Replace String     ${postyaml}     COMPOSITIONIDPLACEHOLDER       ${compositionId}
    ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances  ${updatedpostyaml}  ${auth}
    ${respyaml}=  yaml.Safe Load  ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     201
    RETURN  ${respyaml["instanceId"]}

ChangeStatusAutomationComposition
    [Arguments]  ${compositionId}   ${instanceId}   ${postjson}
    ${auth}=    ClampAuth
    ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}  ${postjson}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}     202

DeleteAutomationComposition
    [Arguments]  ${compositionId}  ${instanceId}
    ${auth}=    ClampAuth
    Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
    ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}     headers=${headers}
    Log    Received response from runtime acm ${resp.text}
    Should Be Equal As Strings    ${resp.status_code}     202


MakeYamlPostRequest
    [Arguments]  ${name}  ${domain}  ${url}  ${postyaml}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  ${name}  http://${domain}  auth=${auth}
    ${headers}  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
    ${resp}=  POST On Session  ${name}  ${url}  data=${postyaml}  headers=${headers}
    Log  Received response from ${name} ${resp.text}
    RETURN  ${resp}

MakeJsonPostRequest
    [Arguments]  ${name}  ${domain}  ${url}  ${postjson}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  ${name}  http://${domain}  auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=  POST On Session  ${name}  ${url}  data=${postjson}  headers=${headers}
    Log  Received response from ${name} ${resp.text}
    RETURN  ${resp}

MakeJsonPutRequest
    [Arguments]  ${name}  ${domain}  ${url}  ${postjson}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  ${name}  http://${domain}  auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=  PUT On Session  ${name}  ${url}  data=${postjson}  headers=${headers}
    Log  Received response from ${name} ${resp.text}
    RETURN  ${resp}

MakeGetRequest
    [Arguments]  ${name}  ${domain}  ${url}  ${auth}
    Log    Creating session http://${domain}
    ${session}=    Create Session      ${name}  http://${domain}   auth=${auth}
    ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
    ${resp}=   GET On Session     ${name}  ${url}     headers=${headers}
    Log    Received response from ${name} {resp.text}
    RETURN  ${resp}

VerifyKafkaInTraces
    [Arguments]  ${domain}    ${service}
    Log  Creating session http://${domain}
    ${session}=  Create Session  jaeger  http://${domain}
    ${tags}=    Create Dictionary    otel.library.name=io.opentelemetry.kafka-clients-2.6    messaging.system=kafka
    ${tags_json}=    evaluate    json.dumps(${tags})    json
    ${params}=    Create Dictionary    service=${service}    tags=${tags_json}    operation=policy-acruntime-participant publish    lookback=1h    limit=10
    ${resp}=  GET On Session  jaeger  /api/traces  params=${params}    expected_status=200
    Log  Received response from jaeger ${resp.text}
    RETURN  ${resp}

VerifyHttpInTraces
    [Arguments]  ${domain}    ${service}
    Log  Creating session http://${domain}
    ${session}=  Create Session  jaeger  http://${domain}
    ${tags}=    Create Dictionary    uri=/v2/compositions/{compositionId}
    ${tags_json}=    evaluate    json.dumps(${tags})    json
    ${params}=    Create Dictionary    service=${service}    tags=${tags_json}    operation=http put /v2/compositions/{compositionId}    lookback=1h    limit=10
    ${resp}=  GET On Session  jaeger  /api/traces  params=${params}    expected_status=200
    Log  Received response from jaeger ${resp.text}
    RETURN  ${resp}
