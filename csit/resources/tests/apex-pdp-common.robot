*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Library     Process
Resource    ${CURDIR}/common-library.robot

*** Keywords ***

DeployPolicy
     [Documentation]    Deploy the policy in apex-pdp engine
     ${postjson}=    Get File  ${CURDIR}/data/policy_deploy.json
     ${postjson}=    evaluate    json.loads('''${postjson}''')    json
     set to dictionary    ${postjson['groups'][0]['deploymentSubgroups'][0]['policies'][0]}    name=${policyName}
     ${postjson}=    evaluate    json.dumps(${postjson})    json
     ${policyadmin}=  PolicyAdminAuth
     PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/deployments/batch  202  ${postjson}  null  ${policyadmin}

RunEventOnApexEngine
    [Documentation]    Send event to verify policy execution
    Create Session   apexSession  http://${APEX_EVENTS_IP}   max_retries=1
    ${data}=    Get Binary File     ${CURDIR}/data/event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    PUT On Session    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200

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

CheckLogMessage
    [Documentation]    Read log messages received and check for expected content.
    [Arguments]    ${status}    ${expectedMsg}
    ${result}=     CheckTopic     APEX-CL-MGT    ${status}
    Should Contain    ${result}    ${expectedMsg}