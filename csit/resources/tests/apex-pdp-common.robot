*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json
Library    Process
Resource    common-library.robot

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
    ${data}=    Get Binary File    ${CURDIR}/data/event.json
    &{headers}=  Create Dictionary    Content-Type=application/json    Accept=application/json
    ${resp}=    PUT On Session    apexSession    /apex/FirstConsumer/EventIn    data=${data}   headers=${headers}
    Should Be Equal As Strings    ${resp.status_code}   200

CheckLogMessage
    [Documentation]    Read log messages received and check for expected content.
    [Arguments]    ${topic}    ${status}    ${expectedMsg}
    ${result}=     CheckKafkaTopic     ${topic}    ${status}
    Should Contain    ${result}    ${expectedMsg}

ValidateEventExecution
    [Arguments]    ${eventStartTime}    ${eventEndTime}    ${eventsNo}
    [Documentation]    Check that X amount of events were executed per second
    ${eventTimeTaken}=  Subtract Date From Date  ${eventEndTime}  ${eventStartTime}
    ${eventResult}=  Set Variable  ${eventTimeTaken * ${1000}}
    ${eventsPerSecond}=  Set Variable  ${${1000} / ${eventResult}}
    Should Be True  ${eventsPerSecond} >= ${eventsNo}
