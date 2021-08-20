*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Resource    ${CURDIR}/../../common-library.robot

*** Test Cases ***

Healthcheck
     [Documentation]  Verify policy distribution health check
     ${resp}=  PerformGetRequest  ${POLICY_DISTRIBUTION_IP}  /healthcheck  200  null
     Should Be Equal As Strings  ${resp.json()['code']}  200

Statistics
     [Documentation]  Verify policy distribution statistics
     ${resp}=  PerformGetRequest  ${POLICY_DISTRIBUTION_IP}  /statistics  200  null
     Should Be Equal As Strings  ${resp.json()['code']}  200

Metrics
    [Documentation]  Verify policy-distribution is exporting prometheus metrics
    ${resp}=  PerformGetRequest  ${POLICY_DISTRIBUTION_IP}  /metrics  200  null
    Should Contain  ${resp.text}  jvm_threads_current

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
