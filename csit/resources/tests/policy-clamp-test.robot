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

CommissionAutomationComposition
     [Documentation]  Commission automation composition definition.
     ${auth}=    ClampAuth
     ${postyaml}=  Get file  ${CURDIR}/data/acelement-usecase.yaml
     ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions  ${postyaml}  ${auth}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${compositionId}  ${respyaml["compositionId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

CommissionAcDefinitionMigrationFrom
     [Documentation]  Commission automation composition definition From.
     ${auth}=    ClampAuth
     ${postyaml}=  Get file  ${CURDIR}/data/ac-definition-migration-from.yaml
     ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions  ${postyaml}  ${auth}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${compositionFromId}  ${respyaml["compositionId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

CommissionAcDefinitionMigrationTo
     [Documentation]  Commission automation composition definition To.
     ${auth}=    ClampAuth
     ${postyaml}=  Get file  ${CURDIR}/data/ac-definition-migration-to.yaml
     ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions  ${postyaml}  ${auth}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${compositionToId}  ${respyaml["compositionId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

PrimeACDefinitions
     [Documentation]  Prime automation composition definition
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionId}  PRIMED

FailPrimeACDefinitionFrom
     [Documentation]  Prime automation composition definition Migration From.
     SetParticipantSimFail
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyFailedPriming  ${compositionFromId}

PrimeACDefinitionFrom
     [Documentation]  Prime automation composition definition Migration From.
     SetParticipantSimSuccess
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionFromId}  PRIMED

PrimeACDefinitionTo
     [Documentation]  Prime automation composition definition Migration To.
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACPriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionToId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionToId}  PRIMED

InstantiateAutomationComposition
     [Documentation]  Instantiate automation composition.
     ${auth}=    ClampAuth
     Run Keyword If    '${TEST_ENV}'=='k8s'    set Suite variable  ${instantiationfile}  AcK8s.json

     ...    ELSE    set Suite variable  ${instantiationfile}  AcDocker.json
     ${postjson}=  Get file  ${CURDIR}/data/${instantiationfile}
     ${updatedpostjson}=   Replace String     ${postjson}     COMPOSITIONIDPLACEHOLDER       ${compositionId}
     ${resp}=   MakeJsonPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances  ${updatedpostjson}  ${auth}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${instanceId}    ${respyaml["instanceId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

InstantiateAutomationCompositionMigrationFrom
     [Documentation]  Instantiate automation composition migration.
     ${auth}=    ClampAuth
     ${postyaml}=  Get file  ${CURDIR}/data/ac-instance-migration-from.yaml
     ${updatedpostyaml}=   Replace String     ${postyaml}     COMPOSITIONIDPLACEHOLDER       ${compositionFromId}
     ${resp}=   MakeYamlPostRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}/instances  ${updatedpostyaml}  ${auth}
     ${respyaml}=  yaml.Safe Load  ${resp.text}
     set Suite variable  ${instanceMigrationId}    ${respyaml["instanceId"]}
     Should Be Equal As Strings    ${resp.status_code}     201

PrepareAutomationComposition
     [Documentation]  Prepare automation composition.
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/PrepareAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  ${compositionId}  ${instanceId}  UNDEPLOYED

DeployAutomationComposition
     [Documentation]  Deploy automation composition.
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
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

ReviewAutomationComposition
     [Documentation]  Review automation composition.
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ReviewAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  ${compositionId}  ${instanceId}  DEPLOYED

FailDeployAutomationCompositionMigration
     [Documentation]  Fail Deploy automation composition.
     SetParticipantSimFail
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}/instances/${instanceMigrationId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyFailDeploy  ${compositionFromId}  ${instanceMigrationId}

DeployAutomationCompositionMigration
     [Documentation]  Deploy automation composition.
     SetParticipantSimSuccess
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/DeployAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}/instances/${instanceMigrationId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionFromId}  ${instanceMigrationId}  DEPLOYED

SendOutPropertiesToRuntime
     [Documentation]  Send Out Properties To Runtime
     ${auth}=    ParticipantAuth
     ${postjson}=  Get file  ${CURDIR}/data/OutProperties.json
     ${updatedpostjson}=   Replace String     ${postjson}     INSTACEIDPLACEHOLDER       ${instanceMigrationId}
     ${updatedpostjson}=   Replace String     ${updatedpostjson}     TEXTPLACEHOLDER       MyTextToSend
     ${resp}=   MakeJsonPutRequest  participant  ${POLICY_PARTICIPANT_SIM_IP}  /onap/policy/simparticipant/v2/datas  ${updatedpostjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     200
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPropertiesUpdated  ${compositionFromId}  ${instanceMigrationId}  MyTextToSend

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
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionFromId}  ${instanceMigrationId}  DEPLOYED

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

UnDeployAutomationComposition
     [Documentation]  UnDeploy automation composition.
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    10 min    5 sec    VerifyDeployStatus  ${compositionId}  ${instanceId}  UNDEPLOYED

FailUnDeployAutomationCompositionMigrationTo
     [Documentation]  Fail UnDeploy automation composition migrated.
     SetParticipantSimFail
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionToId}/instances/${instanceMigrationId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyFailDeploy  ${compositionToId}  ${instanceMigrationId}

UnDeployAutomationCompositionMigrationTo
     [Documentation]  UnDeploy automation composition migrated.
     SetParticipantSimSuccess
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/UndeployAC.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionToId}/instances/${instanceMigrationId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyDeployStatus  ${compositionToId}  ${instanceMigrationId}  UNDEPLOYED

UnInstantiateAutomationComposition
     [Documentation]  Delete automation composition instance.
     ${auth}=    ClampAuth
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}/instances/${instanceId}     headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${compositionId}

FailUnInstantiateAutomationCompositionMigrationTo
     [Documentation]  Fail Delete automation composition instance migrated.
     SetParticipantSimFail
     ${auth}=    ClampAuth
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionToId}/instances/${instanceMigrationId}     headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyFailDeploy  ${compositionToId}  ${instanceMigrationId}

UnInstantiateAutomationCompositionMigrationTo
     [Documentation]  Delete automation composition instance migrated.
     SetParticipantSimSuccess
     ${auth}=    ClampAuth
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/json    Content-Type=application/json
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionToId}/instances/${instanceMigrationId}     headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    1 min    5 sec    VerifyUninstantiated  ${compositionToId}

DePrimeACDefinitions
     [Documentation]  DePrime automation composition definition
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionId}  COMMISSIONED

FailDePrimeACDefinitionsFrom
     [Documentation]  Fail DePrime automation composition definition migration From.
     SetParticipantSimFail
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyFailedPriming  ${compositionFromId}

DePrimeACDefinitionsFrom
     [Documentation]  DePrime automation composition definition migration From.
     SetParticipantSimSuccess
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionFromId}  COMMISSIONED

DePrimeACDefinitionsTo
     [Documentation]  DePrime automation composition definition migration To.
     ${auth}=    ClampAuth
     ${postjson}=  Get file  ${CURDIR}/data/ACDepriming.json
     ${resp}=   MakeJsonPutRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${compositionToId}  ${postjson}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     202
     Wait Until Keyword Succeeds    2 min    5 sec    VerifyPriming  ${compositionToId}  COMMISSIONED

DeleteACDefinition
     [Documentation]  Delete automation composition definition.
     ${auth}=    ClampAuth
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionId}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

DeleteACDefinitionFrom
     [Documentation]  Delete automation composition definition migration From.
     ${auth}=    ClampAuth
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionFromId}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200

DeleteACDefinitionTo
     [Documentation]  Delete automation composition definition migration To.
     ${auth}=    ClampAuth
     Log    Creating session http://${POLICY_RUNTIME_ACM_IP}
     ${session}=    Create Session      policy  http://${POLICY_RUNTIME_ACM_IP}   auth=${auth}
     ${headers}=  Create Dictionary     Accept=application/yaml    Content-Type=application/yaml
     ${resp}=   DELETE On Session     policy  /onap/policy/clamp/acm/v2/compositions/${compositionToId}  headers=${headers}
     Log    Received response from runtime acm ${resp.text}
     Should Be Equal As Strings    ${resp.status_code}     200


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

VerifyFailedPriming
    [Arguments]  ${theCompositionId}
    [Documentation]    Verify the AC definitions are primed to the participants
    ${auth}=    ClampAuth
    ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}  ${auth}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  FAILED

VerifyDeployStatus
     [Arguments]  ${theCompositionId}  ${theInstanceId}  ${deploystate}
     [Documentation]  Verify the Deploy status of automation composition.
     ${auth}=    ClampAuth
     ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  NO_ERROR
     Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['deployState']}  ${deploystate}

VerifyFailDeploy
     [Arguments]  ${theCompositionId}  ${theInstanceId}
     [Documentation]  Verify the Deploy status of automation composition.
     ${auth}=    ClampAuth
     ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     200
     Run Keyword If  ${resp.status_code}==200  Should Be Equal As Strings  ${resp.json()['stateChangeResult']}  FAILED

VerifyPropertiesUpdated
     [Arguments]  ${theCompositionId}  ${theInstanceId}  ${textToFind}
     [Documentation]  Verify the Deploy status of automation composition.
     ${auth}=    ClampAuth
     ${resp}=    MakeGetRequest  ACM  ${POLICY_RUNTIME_ACM_IP}  /onap/policy/clamp/acm/v2/compositions/${theCompositionId}/instances/${theInstanceId}  ${auth}
     Should Be Equal As Strings    ${resp.status_code}     200
     ${respstring}   Convert To String   ${resp.json()}
     Run Keyword If  ${resp.status_code}==200  Should Match Regexp  ${respstring}  ${textToFind}

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

ClampAuth
    ${auth}=    Create List    runtimeUser    zb!XztG34
    RETURN  ${auth}

ParticipantAuth
     ${auth}=    Create List    participantUser    zb!XztG34
    RETURN  ${auth}

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
