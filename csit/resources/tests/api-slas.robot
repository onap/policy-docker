*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json
Resource    common-library.robot

*** Keywords ***
ValidateResponseTimeForApi
    [Arguments]  ${uri}  ${method}
    [Documentation]  Check if uri response is under the 1500ms required time for api metrics
    ValidateResponseTime  api-metrics  ${uri}  ${method}  1500

*** Test Cases ***
WaitForPrometheusServer
    [Documentation]  Sleep time to wait for Prometheus server to gather all metrics
    Sleep    1 minute

ValidateResponseTimeForHealthcheck
    [Documentation]  Validate component healthcheck response time
    ValidateResponseTimeForApi  /healthcheck  GET

ValidateResponseTimeQueryPolicies
    [Documentation]  Validate query policies response time
    ValidateResponseTimeForApi  /policies  GET

ValidateResponseTimeQueryPolicyTypeListVersions
    [Documentation]  Validate query policyType versions response time
    ValidateResponseTime  api-metrics  /policytypes/{policyTypeId}  GET  1500

#Time increased from 200 to 1500 due to slow ONAP machines
ValidateResponseTimeQueryPolicyVersion
    [Documentation]  Validate query policy by version response time
    ValidateResponseTime  api-metrics   /policies/{policyId}/versions/{policyVersion}  GET  1500

ValidateResponseTimeCreatePolicy
    [Documentation]  Validate response time for creating a policy
    ValidateResponseTimeForApi  /policytypes/{policyTypeId}/versions/{policyTypeVersion}/policies  POST

ValidateResponseTimeCreatePolicyType
    [Documentation]  Validate response time for creating a policyType
    ValidateResponseTimeForApi  /policytypes  POST

ValidateResponseTimeDeletePolicy
    [Documentation]  Validate response time for deletion of policies
    ValidateResponseTimeForApi  /policies/{policyId}/versions/{policyVersion}  DELETE

ValidateResponseTimeDeletePolicyType
    [Documentation]  Validate response time for deletion of policyTypes
    ValidateResponseTimeForApi  /policytypes/{policyTypeId}/versions/{versionId}  DELETE
