*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Process
Resource    common-library.robot


*** Test Cases ***

Healthcheck
     [Documentation]    Runs Apex PDP Health check
     ${hcauth}=  HealthCheckAuth
     ${resp}=  PerformGetRequest  ${APEX_IP}  /policy/apex-pdp/v1/healthcheck  200  null  ${hcauth}
     Should Be Equal As Strings    ${resp.json()['code']}    200
     Set Suite Variable    ${pdpName}    ${resp.json()['name']}

ExecuteApexSampleDomainPolicy
     Set Test Variable    ${policyName}    onap.policies.native.apex.Sampledomain
     ${postjson}=  Get file  ./data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     Wait Until Keyword Succeeds    3 min    5 sec    VerifyPdpStatistics    0    0    0    0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     Wait Until Keyword Succeeds    3 min    5 sec    VerifyPdpStatistics    1    1    0    0
     Wait Until Keyword Succeeds    4 min    5 sec    RunEventOnApexEngine
     Wait Until Keyword Succeeds    3 min    5 sec    VerifyPdpStatistics    1    1    1    1

ExecuteApexTestPnfPolicy
     Set Test Variable    ${policyName}    onap.policies.apex.pnf.Test
     ${postjson}=  Get file  ./data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     ${result}=     Run Process    ./data/make_topic.sh     APEX-CL-MGT
     Should Be Equal As Integers    ${result.rc}    0
     Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyTestPnfPolicy

ExecuteApexTestVnfPolicy
     Set Test Variable    ${policyName}    onap.policies.apex.vnf.Test
     ${postjson}=  Get file  ./data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     ${result}=     Run Process    ./data/make_topic.sh     APEX-CL-MGT
     Should Be Equal As Integers    ${result.rc}    0
     Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyTestVnfPolicy

ExecuteApexTestPnfPolicyWithMetadataSet
      Set Test Variable    ${policyName}    onap.policies.apex.pnf.metadataSet.Test
      ${postjson}=  Get file  ./data/${policyName}.json
      CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
      ${postjson}=  Get file  ./data/onap.pnf.metadataSet.Test.json
      CreateNodeTemplate  /policy/api/v1/nodetemplates  200  ${postjson}  1
      DeployPolicy
      Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
      ${result}=     Run Process    ./data/make_topic.sh     APEX-CL-MGT2
      Should Be Equal As Integers    ${result.rc}    0
      Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyTestPnfPolicy

Metrics
     [Documentation]  Verify policy-apex-pdp is exporting prometheus metrics
     ${auth}=  HealthCheckAuth
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

DeployPolicy
     [Documentation]    Deploy the policy in apex-pdp engine
     ${postjson}=    Get file  ./data/policy_deploy.json
     ${postjson}=    evaluate    json.loads('''${postjson}''')    json
     set to dictionary    ${postjson['groups'][0]['deploymentSubgroups'][0]['policies'][0]}    name=${policyName}
     ${postjson}=    evaluate    json.dumps(${postjson})    json
     ${policyadmin}=  PolicyAdminAuth
     PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/deployments/batch  202  ${postjson}  null  ${policyadmin}

RunEventOnApexEngine
    [Documentation]    Send event to verify policy execution
    Create Session   apexSession  http://${APEX_IP}:23324   max_retries=1
    ${data}=    Get Binary File     ./data/event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    PUT On Session    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200

TriggerAndVerifyTestPnfPolicy
    [Documentation]    Send TestPnf policy trigger event to DMaaP and read notifications to verify policy execution
    Create Session   apexSession  http://${DMAAP_IP}:3904   max_retries=1
    ${data}=    Get Binary File     ./data/VesEventForPnfPolicy.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_CL_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword    CheckLogMessage    ACTIVE    VES event has been received. Going to fetch details from AAI.
    Run Keyword    CheckLogMessage    SUCCESS    Received response from AAI successfully. Hostname in AAI matches with the one in Ves event. Going to make the update-config request to CDS.
    Run Keyword    CheckLogMessage    FINAL_SUCCESS    Successfully processed the VES event. Hostname is updated.

TriggerAndVerifyTestVnfPolicy
    [Documentation]    Send TestVnf policy trigger event to DMaaP and read notifications to verify policy execution
    Create Session   apexSession  http://${DMAAP_IP}:3904   max_retries=1
    ${data}=    Get Binary File     ./data/VesEventForVnfPolicy.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_POLICY_EXAMPLE_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword    CheckLogMessage    ACTIVE    VES event has been received. Going to fetch VNF details from AAI.
    Run Keyword    CheckLogMessage    SUCCESS    VNF details are received from AAI successfully. Sending ConfigModify request to CDS.
    Run Keyword    CheckLogMessage    SUCCESS    ConfigModify request is successful. Sending restart request to CDS.
    Run Keyword    CheckLogMessage    FINAL_SUCCESS    Successfully processed the VES Event. Restart is complete.

CheckLogMessage
    [Documentation]    Read log messages received and check for expected content.
    [Arguments]    ${status}    ${expectedMsg}
    ${result}=     Run Process    ./data/wait_topic.sh     APEX-CL-MGT    ${status}
    Log    Received log event on APEX-CL-MGT topic ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0
    Should Contain    ${result.stdout}    ${expectedMsg}

VerifyPdpStatistics
     [Documentation]    Verify pdp statistics after policy execution
     [Arguments]    ${deployCount}    ${deploySuccessCount}    ${executedCount}    ${executedSuccessCount}
     ${policyadmin}=  PolicyAdminAuth
     ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/statistics/defaultGroup/apex/${pdpName}  200  null  ${policyadmin}
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['pdpInstanceId']}  ${pdpName}
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['pdpGroupName']}  defaultGroup
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['pdpSubGroupName']}  apex
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['policyDeployCount']}  ${deployCount}
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['policyDeploySuccessCount']}  ${deploySuccessCount}
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['policyDeployFailCount']}  0
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['policyExecutedCount']}  ${executedCount}
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['policyExecutedSuccessCount']}  ${executedSuccessCount}
     Should Be Equal As Strings    ${resp.json()['defaultGroup']['apex'][0]['policyExecutedFailCount']}  0
