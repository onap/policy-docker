*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Resource    common-library.robot

*** Test Cases ***

Healthcheck
    [Documentation]  Verify policy distribution health check
    ${hcauth}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${DISTRIBUTION_IP}  /healthcheck  200  null  ${hcauth}
    Should Be Equal As Strings  ${resp.json()['code']}  200

InvokeDistributionAndRunEventOnEngine
    Wait Until Keyword Succeeds  5 min  30 sec  InvokeDistributionUsingFile And RunEventOnApexEngine

MetricsAfterExecution
    [Documentation]  Verify policy-distribution is exporting prometheus metrics after execution
    ${hcauth}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${DISTRIBUTION_IP}  /metrics  200  null  ${hcauth}
    Should Contain  ${resp.text}  total_distribution_received_count_total 1.0
    Should Contain  ${resp.text}  distribution_success_count_total 1.0
    Should Contain  ${resp.text}  distribution_failure_count_total 0.0
    Should Contain  ${resp.text}  total_download_received_count_total 1.0
    Should Contain  ${resp.text}  download_success_count_total 1.0
    Should Contain  ${resp.text}  download_failure_count_total 0.0

*** Keywords ***

InvokeDistributionUsingFile And RunEventOnApexEngine
    Copy File  ${CURDIR}/data/csar/csar_temp.csar  ${CURDIR}/data/csar/temp.csar
    Move File  ${CURDIR}/data/csar/temp.csar  ${TEMP_FOLDER}/sample_csar_with_apex_policy.csar
    Sleep  20 seconds  "Waiting for the Policy Distribution to call Policy API and PAP"
    Create Session  apexSession  http://${APEX_EVENTS_IP}  max_retries=1
    ${data}=  Get Binary File  ${CURDIR}/data/event.json
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=  PUT On Session  apexSession  /apex/FirstConsumer/EventIn  data=${data}  headers=${headers}  expected_status=200
    Remove Files  ${CURDIR}/data/temp/sample_csar_with_apex_policy.csar
    Remove Files  ${CURDIR}/data/csar/csar_temp.csar
