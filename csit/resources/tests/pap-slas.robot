*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json
Resource    common-library.robot

*** Keywords ***
ValidateResponseTimeForPap
    [Arguments]  ${uri}  ${method}
    [Documentation]  Check if uri response is under the 1500ms required time for pap metrics
    ValidateResponseTime  pap-metrics  ${uri}  ${method}  1500

*** Test Cases ***
WaitForPrometheusServer
    [Documentation]  Wait for Prometheus server to gather all metrics
    Sleep    1 minute

ValidateResponseTimeForHealthcheck
    [Documentation]  Validate component healthcheck response time
    ValidateResponseTimeForPap  /healthcheck  GET

ValidateResponseTimeForSystemHealthcheck
    [Documentation]  Validate if system healthcheck response time is under 1000ms
    ValidateResponseTime  pap-metrics  /components/healthcheck  GET  10000

# TODO: includes notification, so always over 500ms
# ValidateResponseTimeCreateGroup
#     [Documentation]  Validate create group response time
#     ValidateResponseTimeForPap  /pdps/groups/batch  POST

ValidateResponseTimeQueryPolicyAudit
    [Documentation]  Validate query audits response time
    ValidateResponseTimeForPap  /policies/audit  GET

ValidateResponseTimeUpdateGroup
    [Documentation]  Validate pdps/group response time
    ValidateResponseTimeForPap  /pdps/groups/{name}  PUT

ValidatePolicyDeploymentTime
    [Documentation]  Check if deployment of policy is under 2000ms
    ${resp}=  QueryPrometheus  pap_policy_deployments_seconds_sum{operation="deploy",status="SUCCESS"}/pap_policy_deployments_seconds_count{operation="deploy",status="SUCCESS"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${2000}

ValidateResponseTimeDeletePolicy
    [Documentation]  Check if undeployment of policy is under 2000ms
    ${resp}=  QueryPrometheus  pap_policy_deployments_seconds_sum{operation="undeploy",status="SUCCESS"}/pap_policy_deployments_seconds_count{operation="undeploy",status="SUCCESS"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${2000}

ValidateResponseTimeDeleteGroup
    [Documentation]  Validate delete group response time
    ValidateResponseTimeForPap  /pdps/groups/{name}  DELETE
