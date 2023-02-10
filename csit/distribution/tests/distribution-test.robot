*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Resource    ${CURDIR}/../../common-library.robot

*** Test Cases ***

Healthcheck
    [Documentation]  Verify policy distribution health check
    ${hcauth}=  HealthCheckAuth
    ${resp}=  PerformGetRequest  localhost  ${POLICY_DISTRIBUTION_PORT}  /healthcheck  200  null  ${hcauth}
    Should Be Equal As Strings  ${resp.json()['code']}  200

Statistics
    [Documentation]  Verify policy distribution statistics
    ${hcauth}=  HealthCheckAuth
    ${resp}=  PerformGetRequest  localhost  ${POLICY_DISTRIBUTION_PORT}  /statistics  200  null  ${hcauth}
    Should Be Equal As Strings  ${resp.json()['code']}  200

Metrics
    [Documentation]  Verify policy-distribution is exporting prometheus metrics
    ${hcauth}=  HealthCheckAuth
    ${resp}=  PerformGetRequest  localhost  ${POLICY_DISTRIBUTION_PORT}  /metrics  200  null  ${hcauth}
    Should Contain  ${resp.text}  total_distribution_received_count_total 0.0
    Should Contain  ${resp.text}  distribution_success_count_total 0.0
    Should Contain  ${resp.text}  distribution_failure_count_total 0.0
    Should Contain  ${resp.text}  total_download_received_count_total 0.0
    Should Contain  ${resp.text}  download_success_count_total 0.0
    Should Contain  ${resp.text}  download_failure_count_total 0.0

InvokeDistributionAndRunEventOnEngine
    Wait Until Keyword Succeeds  5 min  30 sec  InvokeDistributionUsingFile And RunEventOnApexEngine

MetricsAfterExecution
    [Documentation]  Verify policy-distribution is exporting prometheus metrics after execution
    ${hcauth}=  HealthCheckAuth
    ${resp}=  PerformGetRequest  localhost  ${POLICY_DISTRIBUTION_PORT}  /metrics  200  null  ${hcauth}
    Should Contain  ${resp.text}  total_distribution_received_count_total 1.0
    Should Contain  ${resp.text}  distribution_success_count_total 1.0
    Should Contain  ${resp.text}  distribution_failure_count_total 0.0
    Should Contain  ${resp.text}  total_download_received_count_total 1.0
    Should Contain  ${resp.text}  download_success_count_total 1.0
    Should Contain  ${resp.text}  download_failure_count_total 0.0

*** Keywords ***

InvokeDistributionUsingFile And RunEventOnApexEngine
    Copy File  ${SCRIPT_DIR}/csar/csar_temp.csar  ${SCRIPT_DIR}/csar/temp.csar
    Move File  ${SCRIPT_DIR}/csar/temp.csar  ${SCRIPT_DIR}/temp/sample_csar_with_apex_policy.csar
    Sleep  20 seconds  "Waiting for the Policy Distribution to call Policy API and PAP"
    Create Session  apexSession  http://localhost:23324  max_retries=1
    ${data}=  Get Binary File  ${CURDIR}${/}data${/}event.json
    &{headers}=  Create Dictionary  Content-Type=application/json  Accept=application/json
    ${resp}=  PUT On Session  apexSession  /apex/FirstConsumer/EventIn  data=${data}  headers=${headers}  expected_status=200
    Remove Files  ${SCRIPT_DIR}/temp/sample_csar_with_apex_policy.csar
