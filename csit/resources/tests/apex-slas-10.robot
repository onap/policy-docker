*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    DateTime
Library    Process
Library    json
Resource    common-library.robot
Resource    apex-pdp-common.robot

*** Test Cases ***
Healthcheck
     [Documentation]    Runs Apex PDP Health check
     ${hcauth}=  PolicyAdminAuth
     ${resp}=  PerformGetRequest  ${APEX_IP}  /policy/apex-pdp/v1/healthcheck  200  null  ${hcauth}
     Should Be Equal As Strings    ${resp.json()['code']}    200
     Set Suite Variable    ${pdpName}    ${resp.json()['name']}

ValidatePolicyExecutionAndEventRateLowComplexity
    [Documentation]  Validate that a moderate complexity policity can be executed in less than 100ms and minimum 100 events triggered per second
    Set Test Variable    ${policyName}    onap.policies.apex.pnf.metadataSet.Test
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    CreatePolicySuccessfully    /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
    ${postjson}=  Get File  ${CURDIR}/data/onap.pnf.metadataSet.Test.json
    CreateNodeTemplate  /policy/api/v1/nodetemplates  201  ${postjson}  1
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    GetKafkaTopic     apex-cl-mgt2
    ${data}=    Get Binary File     ${CURDIR}/data/VesEventForVnfPolicy.json
    ${eventStartTime}=  Get Current Date
    ${resp}=    Run Process    ${CURDIR}/kafka_producer.py    unauthenticated.dcae_policy_example_output    ${data}    ${KAFKA_IP}
    ${eventEndTime}=  Get Current Date
    ValidateEventExecution    ${eventStartTime}  ${eventEndTime}  100

ValidatePolicyExecutionAndEventRateHighComplexity
    [Documentation]  Validate that a high complexity policity can be executed in less than 5000ms and minimum 2 events triggered per second
    Set Test Variable    ${policyName}    onap.policies.native.apex.Sampledomain
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    CreatePolicySuccessfully  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
    DeployPolicy
    Create Session   apexSession  http://${APEX_EVENTS_IP}   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    Sleep  60s
    ${eventStartTime}=  Get Current Date
    ${resp}=    PUT On Session    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    ${eventEndTime}=  Get Current Date
    Should Be Equal As Strings    ${resp.status_code}   200
    ValidateEventExecution    ${eventStartTime}  ${eventEndTime}  2

ValidatePolicyExecutionAndEventRateModerateComplexity
    [Documentation]  Validate that a low complexity policity can be executed in less than 1000ms and minimum 10 events triggered per second
    Set Test Variable    ${policyName}    onap.policies.apex.pnf.Test
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    CreatePolicySuccessfully   /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    GetKafkaTopic     apex-cl-mgt
    ${data}=    Get Binary File     ${CURDIR}/data/VesEventForPnfPolicy.json
    ${eventStartTime}=  Get Current Date
    ${resp}=    Run Process    ${CURDIR}/kafka_producer.py    unauthenticated.dcae_cl_output    ${data}    ${KAFKA_IP}
    ${eventEndTime}=  Get Current Date
    ValidateEventExecution    ${eventStartTime}  ${eventEndTime}  10

WaitForPrometheusServer
    [Documentation]  Sleep time to wait for Prometheus server to gather all metrics
    Sleep    2 minutes

ValidatePolicyExecutionTimes
    [Documentation]    Validate policy execution times using prometheus metrics
    ValidatePolicyExecution   pdpa_engine_average_execution_time_seconds{engine_instance_id="NSOApexEngine-0:0.0.1", instance="policy-apex-pdp:6969", job="apex-pdp-metrics"}  5000
    ValidatePolicyExecution   pdpa_engine_average_execution_time_seconds{engine_instance_id="MyApexEngine-0:0.0.1"}  1000
    ValidatePolicyExecution   pdpa_engine_average_execution_time_seconds{engine_instance_id="NSOApexEngine-1:0.0.1", instance="policy-apex-pdp:6969", job="apex-pdp-metrics"}  100
