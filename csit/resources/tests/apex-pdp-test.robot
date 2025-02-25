*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json
Library    Process
Resource    common-library.robot
Resource    apex-pdp-common.robot

*** Test Cases ***

Healthcheck
    [Documentation]    Runs Apex PDP Health check
    ${hcauth}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${APEX_IP}  /policy/apex-pdp/v1/healthcheck  200  null  ${hcauth}
    Should Be Equal As Strings    ${resp.json()['code']}    200
    Set Suite Variable    ${pdpName}    ${resp.json()['name']}

ExecuteApexSampleDomainPolicy
    # [Tags]    docker
    Set Test Variable    ${policyName}    onap.policies.native.apex.Sampledomain
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    CreatePolicySuccessfully  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    Wait Until Keyword Succeeds    4 min    5 sec    RunEventOnApexEngine

ExecuteApexTestPnfPolicy
    Set Test Variable    ${policyName}    onap.policies.apex.pnf.Test
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    CreatePolicySuccessfully  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    GetKafkaTopic    apex-cl-mgt
    TriggerAndVerifyTestPnfPolicy    apex-cl-mgt

#ExecuteApexTestVnfPolicy
#    Set Test Variable    ${policyName}    onap.policies.apex.vnf.Test
#    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
#    CreatePolicySuccessfully  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
#    DeployPolicy
#    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
#    GetKafkaTopic    apex-cl-mgt
#    TriggerAndVerifyTestVnfPolicy    apex-cl-mgt

ExecuteApexTestPnfPolicyWithMetadataSet
    Set Test Variable    ${policyName}    onap.policies.apex.pnf.metadataSet.Test
    ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
    CreatePolicySuccessfully  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  ${postjson}  ${policyName}  1.0.0
    ${postjson}=  Get File  ${CURDIR}/data/onap.pnf.metadataSet.Test.json
    CreateNodeTemplate  /policy/api/v1/nodetemplates  201  ${postjson}  1
    DeployPolicy
    Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
    GetKafkaTopic    apex-cl-mgt2
    TriggerAndVerifyTestPnfPolicy    apex-cl-mgt2

Metrics
    [Documentation]  Verify policy-apex-pdp is exporting prometheus metrics
    ${auth}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${APEX_IP}  /metrics  200  null  ${auth}
    Should Contain  ${resp.text}  pdpa_policy_deployments_total{operation="deploy",status="TOTAL"} 3.0
    Should Contain  ${resp.text}  pdpa_policy_deployments_total{operation="deploy",status="SUCCESS"} 3.0
    Should Contain  ${resp.text}  pdpa_policy_executions_total{status="SUCCESS"} 3.0
    Should Contain  ${resp.text}  pdpa_policy_executions_total{status="TOTAL"} 3.0
    Should Match  ${resp.text}  *pdpa_engine_event_executions{engine_instance_id="NSOApexEngine-*:0.0.1"}*
    Should Match  ${resp.text}  *pdpa_engine_event_executions{engine_instance_id="MyApexEngine-*:0.0.1"}*
    Should Match  ${resp.text}  *pdpa_engine_state{engine_instance_id=*} 2.0*
    Should Contain  ${resp.text}  pdpa_engine_event_executions
    Should Contain  ${resp.text}  pdpa_engine_average_execution_time_seconds
    Should Contain  ${resp.text}  pdpa_engine_last_execution_time_bucket
    Should Contain  ${resp.text}  pdpa_engine_last_execution_time_count
    Should Contain  ${resp.text}  pdpa_engine_last_execution_time_sum
    Should Match  ${resp.text}  *pdpa_engine_last_start_timestamp_epoch{engine_instance_id="NSOApexEngine-*:0.0.1"}*E12*
    Should Match  ${resp.text}  *pdpa_engine_last_start_timestamp_epoch{engine_instance_id="MyApexEngine-*:0.0.1"}*E12*
    Should Contain  ${resp.text}  jvm_threads_current

*** Keywords ***

TriggerAndVerifyTestPnfPolicy
    [Documentation]    Send TestPnf policy trigger event to Kafka and read notifications to verify policy execution
    [Arguments]    ${topic}
    ${data}=    Get Binary File    ${CURDIR}/data/VesEventForPnfPolicy.json
    ${resp}=    Run Process    ${CURDIR}/kafka_producer.py    unauthenticated.dcae_cl_output    ${data}    ${KAFKA_IP}
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    ACTIVE    VES event has been received. Going to fetch details from AAI.
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    SUCCESS    Received response from AAI successfully. Hostname in AAI matches with the one in Ves event. Going to make the update-config request to CDS.
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    FINAL_SUCCESS    Successfully processed the VES event. Hostname is updated.

TriggerAndVerifyTestVnfPolicy
    [Documentation]    Send TestVnf policy trigger event to Kafka and read notifications to verify policy execution
    [Arguments]    ${topic}
    ${data}=    Get Binary File    ${CURDIR}/data/VesEventForVnfPolicy.json
    ${resp}=    Run Process    ${CURDIR}/kafka_producer.py    unauthenticated.dcae_policy_example_output    ${data}    ${KAFKA_IP}
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    ACTIVE    VES event has been received. Going to fetch VNF details from AAI.
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    SUCCESS    VNF details are received from AAI successfully. Sending ConfigModify request to CDS.
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    SUCCESS    ConfigModify request is successful. Sending restart request to CDS.
    Wait Until Keyword Succeeds    4 x    10 sec    CheckLogMessage    ${topic}    FINAL_SUCCESS    Successfully processed the VES Event. Restart is complete.
