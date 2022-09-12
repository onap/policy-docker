*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Process
Resource    ${CURDIR}/../../common-library.robot


*** Test Cases ***

Healthcheck
     [Documentation]    Runs Apex PDP Health check
     ${resp}=    PerformGetRequest    ${APEX_IP}    /policy/apex-pdp/v1/healthcheck    200    null
     Should Be Equal As Strings    ${resp.json()['code']}    200
     Set Suite Variable    ${pdpName}    ${resp.json()['name']}

Metrics
     [Documentation]  Verify policy-apex-pdp is exporting prometheus metrics
     ${resp}=  PerformGetRequest  ${APEX_IP}  /metrics  200  null
     Should Contain  ${resp.text}  jvm_threads_current

ExecuteApexSampleDomainPolicy
     Set Test Variable    ${policyName}    onap.policies.native.apex.Sampledomain
     ${postjson}=  Get file  ${CURDIR}/data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     Wait Until Keyword Succeeds    3 min    5 sec    VerifyPdpStatistics    0    0    0    0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     Wait Until Keyword Succeeds    3 min    5 sec    VerifyPdpStatistics    1    1    0    0
     Wait Until Keyword Succeeds    4 min    5 sec    RunEventOnApexEngine
     Wait Until Keyword Succeeds    3 min    5 sec    VerifyPdpStatistics    1    1    1    1

ExecuteApexControlLoopPolicy
     Set Test Variable    ${policyName}    onap.policies.apex.Simplecontrolloop
     ${postjson}=  Get file  ${CURDIR}/data/${policyName}.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.native.Apex/versions/1.0.0/policies  200  ${postjson}  ${policyName}  1.0.0
     DeployPolicy
     Wait Until Keyword Succeeds    2 min    5 sec    QueryPolicyStatus  ${policyName}  defaultGroup  apex  ${pdpName}  onap.policies.native.Apex
     ${result}=     Run Process    ${SCRIPTS}/make_topic.sh     APEX-CL-MGT
     Should Be Equal As Integers    ${result.rc}    0
     Wait Until Keyword Succeeds    2 min    5 sec    TriggerAndVerifyControlLoopPolicy

*** Keywords ***


DeployPolicy
     [Documentation]    Deploy the policy in apex-pdp engine
     ${postjson}=    Get file  ${CURDIR}/data/policy_deploy.json
     ${postjson}=    evaluate    json.loads('''${postjson}''')    json
     set to dictionary    ${postjson['groups'][0]['deploymentSubgroups'][0]['policies'][0]}    name=${policyName}
     ${postjson}=    evaluate    json.dumps(${postjson})    json
     PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/deployments/batch  202  ${postjson}  null

RunEventOnApexEngine
    [Documentation]    Send event to verify policy execution
    Create Session   apexSession  http://${APEX_IP}:23324   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}${/}data${/}event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    PUT On Session    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200

TriggerAndVerifyControlLoopPolicy
    [Documentation]    Send event to DMaaP and read notifications to verify policy execution
    Create Session   apexSession  http://${DMAAP_IP}:3904   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/VesEvent.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    POST On Session    apexSession    /events/unauthenticated.DCAE_CL_OUTPUT    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200
    Run Keyword    CheckLogMessage    VES event has been received. Going to fetch details from AAI.
    Run Keyword    CheckLogMessage    Received response from AAI successfully. Hostname in AAI matches with the one in Ves event. Going to make the update-config request to CDS.
    Run Keyword    CheckLogMessage    Successfully processed the VES event. Hostname is updated.

CheckLogMessage
    [Documentation]    Read log messages received and check for expected content.
    [Arguments]    ${expectedMsg}
    ${result}=     Run Process    ${SCRIPTS}/wait_topic.sh     APEX-CL-MGT    PNF101
    Log    Received log event on APEX-CL-MGT topic ${result.stdout}
    Should Be Equal As Integers    ${result.rc}    0
    Should Contain    ${result.stdout}    ${expectedMsg}

VerifyPdpStatistics
     [Documentation]    Verify pdp statistics after policy execution
     [Arguments]    ${deployCount}    ${deploySuccessCount}    ${executedCount}    ${executedSuccessCount}
     ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/statistics/defaultGroup/apex/${pdpName}  200  null
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
