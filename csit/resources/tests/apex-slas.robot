*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json
Resource    ${CURDIR}/common-library.robot

*** Keywords ***
ValidateResponseTimeForApex
    [Arguments]  ${uri}  ${method}
    [Documentation]  Check if uri response is under the 500ms required time for apex metrics
    ValidateResponseTime  apex-metrics  ${uri}  ${method}  500

*** Test Cases ***
WaitForPrometheusServer
    [Documentation]  Sleep time to wait for Prometheus server to gather all metrics
    Sleep    1 minute

ValidateResponseTimeForHealthcheck
    [Documentation]  Validate component healthcheck response time
    ValidateResponseTimeForApex  /healthcheck  GET

ValidateResponseTimePDPADeployPolicyTotal
    [Documentation]  Validate pdpa policy deployment total
    ${resp}=  QueryPrometheus  pdpa_policy_deployments_total{operation="deploy",status="TOTAL"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${2000}

ValidateResponseTimePDPADeployPolicySuccess
    [Documentation]  Validate pdpa policy deployment success
    ${resp}=  QueryPrometheus  pdpa_policy_deployments_total{operation="deploy",status="SUCCESS"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${2000}

ValidateResponseTimePolicyExecutionSuccess
    [Documentation]  Validate pdpa policy execution success
    ${resp}=  QueryPrometheus  pdpa_policy_executions_total{status="SUCCESS"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${2000}

ValidateResponseTimePolicyExecutionTotal
    [Documentation]  Validate pdpa policy execution total
    ${resp}=  QueryPrometheus  pdpa_policy_executions_total{status="TOTAL"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${2000}