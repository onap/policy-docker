*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    Process
Library     json
Resource   common-library.robot

*** Variables ***
${OPA_PDP_HOST}    /policy/pdpx/v1/healthcheck
${url}    /policy/pdpx/v1/decision

*** Test Cases ***
Healthcheck
    [Documentation]    Verify OPA PDP health check
    PdpxGetReq  ${OPA_PDP_HOST}  <Response [200]>

RetrieveSuccessfulRequest
    [Documentation]  Get Decision Request Successful for Opa Pdp
    DecisionRequest  onap.policy.opa.pdp.decision.request.json  PERMIT  200

RetrieveDenyRequest
    [Documentation]  Get Decision Request DENY for Opa Pdp
    DecisionRequest  onap.policy.opa.pdp.decision.requestfailure.json  DENY  200

*** comments ***
| RetrieveFailureRequest
| |[Documentation] | Get Decision Request INDETERMINATE for Opa Pdp ***
| | |DecisionRequest  onap.policy.opa.pdp.decision.requestIndeterminate.json  INDETERMINATE  200 ***

RetrieveFailureBadRequest
    [Documentation]  Get Decision Request Failure Bad Request for Opa Pdp
    DecisionRequest  onap.policy.opa.pdp.decision.badRequest.json  BAD_REQUEST  400
*** Keywords ***
PdpxGetReq
    [Documentation]     Verify the response of Health Check is Successful
    [Arguments]   ${url}  ${status}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest  ${POLICY_OPA_IP}  ${url}  200  null  ${hcauth}
    Should Be Equal As Strings    ${resp}   ${status}

DecisionRequest
    [Arguments]  ${jsonfile}  ${keyword}  ${status}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${resp}=  DecisionPostReq  ${postjson}  ${status}  abbrev=true
    Should Contain  ${resp.text}  ${keyword}

DecisionPostReq
    [Arguments]  ${postjson}  ${status}  ${abbr}
    ${expectedStatus}=    Set Variable    ${status}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPostRequest   ${POLICY_OPA_IP}  ${url}  ${expectedStatus}  ${postjson}  ${abbr}  ${hcauth}
    RETURN  ${resp}
