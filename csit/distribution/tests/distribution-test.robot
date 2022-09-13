*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

Healthcheck
     [Documentation]  Verify policy distribution health check
     ${resp}=  PeformGetRequest  /healthcheck  200
     Should Be Equal As Strings  ${resp.json()['code']}  200

Statistics
     [Documentation]  Verify policy distribution statistics
     ${resp}=  PeformGetRequest  /statistics  200
     Should Be Equal As Strings  ${resp.json()['code']}  200

InvokeDistributionAndRunEventOnEngine
     Wait Until Keyword Succeeds  5 min  30 sec  InvokeDistributionUsingFile And RunEventOnApexEngine

*** Keywords ***

InvokeDistributionUsingFile And RunEventOnApexEngine
    Copy File  ${SCRIPT_DIR}/csar/csar_temp.csar  ${SCRIPT_DIR}/csar/temp.csar
    Move File  ${SCRIPT_DIR}/csar/temp.csar  ${SCRIPT_DIR}/temp/sample_csar_with_apex_policy.csar
    Sleep  20 seconds  "Waiting for the Policy Distribution to call Policy API and PAP"
    Create Session  apexSession  http://${APEX_IP}:23324  max_retries=1
    ${data}=  Get Binary File  ${CURDIR}${/}data${/}event.json
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=  PUT On Session  apexSession  /apex/FirstConsumer/EventIn  data=${data}  headers=${headers}  expected_status=200
    Remove Files  ${SCRIPT_DIR}/temp/sample_csar_with_apex_policy.csar

PeformGetRequest
     [Arguments]  ${url}  ${expectedstatus}
     ${auth}=  Create List  healthcheck  zb!XztG34
     Log  Creating session http://${POLICY_DISTRIBUTION_IP}:6969
     ${session}=  Create Session  policy  http://${POLICY_DISTRIBUTION_IP}:6969  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
     ${resp}=  GET On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}
