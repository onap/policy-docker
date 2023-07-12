*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Process
Resource    ${CURDIR}/common-library.robot
Resource    ${CURDIR}/apex-pdp-common.robot

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
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     Wait Until Keyword Succeeds    4 min    5 sec    RunEventOnApexEngine

ExecuteApexTestPnfPolicy
     Set Test Variable    ${policyName}    onap.policies.apex.pnf.Test
     ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     GetTopic     APEX-CL-MGT
     Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyTestPnfPolicy

ExecuteApexTestVnfPolicy
     Set Test Variable    ${policyName}    onap.policies.apex.vnf.Test
     ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     GetTopic     APEX-CL-MGT
     Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyTestVnfPolicy

ExecuteApexTestPnfPolicyWithMetadataSet
      Set Test Variable    ${policyName}    onap.policies.apex.pnf.metadataSet.Test
      ${postjson}=  Get File  ${CURDIR}/data/${policyName}.json
      CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
      ${postjson}=  Get File  ${CURDIR}/data/onap.pnf.metadataSet.Test.json
      CreateNodeTemplate  /policy/api/v1/nodetemplates  200  ${postjson}  1
      DeployPolicy
      Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
      GetTopic     APEX-CL-MGT2
      Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyTestPnfPolicy

Metrics
     [Documentation]  Verify policy-apex-pdp is exporting prometheus metrics
     ${auth}=  PolicyAdminAuth
     ${resp}=  PerformGetRequest  ${APEX_IP}  /metrics  200  null  ${auth}
     Should Contain  ${resp.text}  pdpa_policy_deployments_total{operation="deploy",status="TOTAL",} 4.0
     Should Contain  ${resp.text}  pdpa_policy_deployments_total{operation="deploy",status="SUCCESS",} 4.0
     Should Contain  ${resp.text}  pdpa_policy_executions_total{status="SUCCESS",} 3.0
     Should Contain  ${resp.text}  pdpa_policy_executions_total{status="TOTAL",} 3.0
     Should Match  ${resp.text}  *pdpa_engine_event_executions{engine_instance_id="NSOApexEngine-*:0.0.1",}*
     Should Match  ${resp.text}  *pdpa_engine_event_executions{engine_instance_id="MyApexEngine-*:0.0.1",}*
     Should Match  ${resp.text}  *pdpa_engine_state{engine_instance_id=*,} 2.0*
     Should Contain  ${resp.text}  pdpa_engine_event_executions
     Should Contain  ${resp.text}  pdpa_engine_average_execution_time_seconds
     Should Contain  ${resp.text}  pdpa_engine_last_execution_time_bucket
     Should Contain  ${resp.text}  pdpa_engine_last_execution_time_count
     Should Contain  ${resp.text}  pdpa_engine_last_execution_time_sum
     Should Match  ${resp.text}  *pdpa_engine_last_start_timestamp_epoch{engine_instance_id="NSOApexEngine-*:0.0.1",}*E12*
     Should Match  ${resp.text}  *pdpa_engine_last_start_timestamp_epoch{engine_instance_id="MyApexEngine-*:0.0.1",}*E12*
     Should Contain  ${resp.text}  jvm_threads_current

*** Keywords ***

TriggerAndVerifyTestPnfPolicy
    [Documentation]    Send TestPnf policy trigger event to DMaaP and read notifications to verify policy execution
    Create Session   apexSession  http://${DMAAP_IP}   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/VesEventForPnfPolicy.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_CL_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword    CheckLogMessage    ACTIVE    VES event has been received. Going to fetch details from AAI.
    Run Keyword    CheckLogMessage    SUCCESS    Received response from AAI successfully. Hostname in AAI matches with the one in Ves event. Going to make the update-config request to CDS.
    Run Keyword    CheckLogMessage    FINAL_SUCCESS    Successfully processed the VES event. Hostname is updated.

TriggerAndVerifyTestVnfPolicy
    [Documentation]    Send TestVnf policy trigger event to DMaaP and read notifications to verify policy execution
    Create Session   apexSession  http://${DMAAP_IP}   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/VesEventForVnfPolicy.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_POLICY_EXAMPLE_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword    CheckLogMessage    ACTIVE    VES event has been received. Going to fetch VNF details from AAI.
    Run Keyword    CheckLogMessage    SUCCESS    VNF details are received from AAI successfully. Sending ConfigModify request to CDS.
    Run Keyword    CheckLogMessage    SUCCESS    ConfigModify request is successful. Sending restart request to CDS.
    Run Keyword    CheckLogMessage    FINAL_SUCCESS    Successfully processed the VES Event. Restart is complete.
