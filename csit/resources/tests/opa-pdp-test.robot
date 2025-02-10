*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    Process
Library     json
Resource   common-library.robot

*** Variables ***
${OPA_PDP_HOST}    /policy/pdpo/v1/healthcheck
${url}    /policy/pdpo/v1/decision

*** Test Cases ***
Healthcheck
    [Documentation]    Verify OPA PDP health check
    PdpxGetReq  ${OPA_PDP_HOST}  <Response [200]>

ValidatingPolicyWithoutPolicyFilter
   [Documentation]    Validating the policy without giving policy filter
   ValidatePolicyResponseWithoutFilter  onap.policy.opa.pdp.decision.request.json  400  onap.policy.opa.pdp.decision.request.output.json

ValidatingPolicyWithPolicyFilter
   [Documentation]    Validating the policy with policy filter
   ValidatePolicyResponse  onap.policy.opa.pdp.decision.request_filter.json  200  onap.policy.opa.pdp.decision.filter_response.json

ValidatingPolicyWithEmptyPolicyFilter
   [Documentation]    Validating the policy with empty policy filter
   ValidatePolicyResponse  onap.policy.opa.pdp.decision.request_filter_empty.json  200  onap.policy.opa.pdp.decision.empty_filter_response.json

*** Keywords ***
PdpxGetReq
    [Documentation]     Verify the response of Health Check is Successful
    [Arguments]   ${url}  ${status}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest  ${POLICY_OPA_IP}  ${url}  200  null  ${hcauth}
    Should Be Equal As Strings    ${resp}   ${status}

ValidatePolicyResponse
    [Documentation]    Validating the output for the policy
    [Arguments]  ${jsonfile}  ${status}  ${jsonfile1}
    ${expectedStatus}=    Set Variable    ${status}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${expected_data}=  Get file  ${CURDIR}/data/${jsonfile1}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPostRequest   ${POLICY_OPA_IP}  ${url}  ${expectedStatus}  ${postjson}  abbrev=true  ${hcauth}
    ${response_data}=    Get From Dictionary    ${resp.json()}    output
    ${expected_value}=    Evaluate    json.loads('''${expected_data}''')    json
    ${expected_output}=    Get From Dictionary    ${expected_value}    output
    Dictionaries Should Be Equal    ${response_data}  ${expected_output}

ValidatePolicyResponseWithoutFilter
    [Documentation]    Validating the output for the policy
    [Arguments]  ${jsonfile}  ${status}  ${jsonfile1}
    ${expectedStatus}=    Set Variable    ${status}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${expected_data}=  Get file  ${CURDIR}/data/${jsonfile1}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPostRequest   ${POLICY_OPA_IP}  ${url}  ${expectedStatus}  ${postjson}  abbrev=true  ${hcauth}
    ${response_data}=    Get From Dictionary    ${resp.json()}    responseCode
    ${expected_value}=    Evaluate    json.loads('''${expected_data}''')    json
    ${expected_output}=    Get From Dictionary    ${expected_value}    responseCode
    Should Be Equal As Strings   ${response_data}  ${expected_output}


