*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    DateTime
Library    Process
Library    json
Resource    ${CURDIR}/common-library.robot
Resource    ${CURDIR}/apex-pdp-common.robot

*** Keywords ***

ValidatePolicyExecution
    [Arguments]  ${executionStartTime}  ${executionEndTime}  ${executionTime}
    [Documentation]  Check that policy execution under X milliseconds
    ${executionTimeTaken}=  Subtract Date From Date  ${executionEndTime}  ${executionStartTime}
    ${executionResult}=  Set Variable  ${executionTimeTaken * ${1000}}
    Should Be True  ${executionResult} <= ${executionTime}

ValidateEventExecution
    [Arguments]  ${eventStartTime}  ${eventEndTime}  ${eventsNo}
    [Documentation]    Check that X amount of events were exeuted per second
    ${eventTimeTaken}=  Subtract Date From Date  ${eventEndTime}  ${eventStartTime}
    ${eventResult}=  Set Variable  ${eventTimeTaken * ${1000}}
    ${eventsPerSecond}=  Set Variable  ${${1000} / ${eventResult}}
    Should Be True  ${eventsPerSecond} >= ${eventsNo}

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Apex PDP Health check
     ${hcauth}=  PolicyAdminAuth
     ${resp}=  PerformGetRequest  ${APEX_IP}  /policy/apex-pdp/v1/healthcheck  200  null  ${hcauth}
     Should Be Equal As Strings    ${resp.json()['code']}    200
     Set Suite Variable    ${pdpName}    ${resp.json()['name']}

ValidatePolicyExecutionAndEventRateLowComplexity
    [Documentation]  Validate that a moderate complexity policity can be executed in less than 1000ms and minimum 1 events triggered per second
    Set Test Variable    ${policyName}    onap.policies.apex.pnf.Test
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    ${executionStartTime}=  Get Current Date
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    GetTopic     APEX-CL-MGT
    Create Session   apexSession  http://${DMAAP_IP}   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/VesEventForPnfPolicy.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${eventStartTime}=  Get Current Date
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_CL_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${eventEndTime}=  Get Current Date
    ${executionEndTime}=  Get Current Date
    ValidatePolicyExecution    ${executionStartTime}  ${executionEndTime}  600
    ValidateEventExecution    ${eventStartTime}  ${eventEndTime}  10

ValidatePolicyExecutionAndEventRateModerateComplexity
    [Documentation]  Validate that a low complexity policity can be executed in less than 100ms and minimum 10 events triggered per second
    Set Test Variable    ${policyName}    onap.policies.native.apex.Sampledomain
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    ${executionStartTime}=  Get Current Date
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
    ${executionEndTime}=  Get Current Date
    DeployPolicy
    ${eventStartTime}=  Get Current Date
    Wait Until Keyword Succeeds    4 min    5 sec    RunEventOnApexEngine
    ${eventEndTime}=  Get Current Date
    ValidatePolicyExecution    ${executionStartTime}  ${executionEndTime}  1000
    ValidateEventExecution    ${eventStartTime}  ${eventEndTime}  1

ValidatePolicyExecutionAndEventRateHighComplexity
    [Documentation]  Validate that a high complexity policity can be executed in less than 5000ms and minimum 0.2 events triggered per second
    Set Test Variable    ${policyName}    onap.policies.apex.pnf.metadataSet.Test
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    ${executionStartTime}=  Get Current Date
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
    ${postjson}=  Get File  ${CURDIR}/data/onap.pnf.metadataSet.Test.json
    CreateNodeTemplate  /policy/api/v1/nodetemplates  200  ${postjson}  1
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    GetTopic     APEX-CL-MGT2
    Create Session   apexSession  http://${DMAAP_IP}   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/VesEventForVnfPolicy.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${eventStartTime}=  Get Current Date
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_POLICY_EXAMPLE_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    ${eventEndTime}=  Get Current Date
    ${executionEndTime}=  Get Current Date
    ValidatePolicyExecution    ${executionStartTime}  ${executionEndTime}  5000
    ValidateEventExecution    ${eventStartTime}  ${eventEndTime}  0.2