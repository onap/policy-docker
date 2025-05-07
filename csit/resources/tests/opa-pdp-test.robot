*** Settings ***
Library    RequestsLibrary
Library    Collections
Library    OperatingSystem
Library    Process
Library     json
Resource   common-library.robot
Resource   opa-pdp-common.robot
*** Variables ***
${OPA_PDP_HOST}    /policy/pdpo/v1/healthcheck
${url}    /policy/pdpo/v1/decision
${DATA_URL}    /policy/pdpo/v1/data/

*** Test Cases ***
Healthcheck
    [Documentation]    Verify OPA PDP health check
    PdpxGetReq  ${OPA_PDP_HOST}  <Response [200]>

ValidateDataBeforePolicyDeployment
    ValidateGetDynamicData  ${DATA_URL}  200  onap.policy.opa.pdp.data-empty.json  data

ValidatesZonePolicy
    CreateOpaPolicy  onap.policy.opa.pdp.policy-zone-create.yaml  zoneB  1.0.3  201
    DeployOpaPolicy  onap.policy.opa.pdp.policy-zone-deploy.json  zoneB
    ${URL_CONTEXT}=    Set Variable    node/zoneB/zone
    ${DYNAMIC_URL}=    Set Variable    ${DATA_URL}${URL_CONTEXT}
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-zone-output.json  data
    ValidatePolicyResponse  onap.policy.policy.opa.pdp.decision.zone-policy-input.json  200  onap.policy.opa.pdp.decision.zone-policy-output.json
    ValidateIncorrectPolicyNameResponse  onap.policy.opa.pdp.decision.zone-incorrect-policyname.json  400
    ValidateIncorrectPolicyFilterResponse  onap.policy.opa.pdp.decision.zone-incorrect-policyfilter.json  200
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/zoneB  202
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/zoneB  400

ValidatesVehiclePolicy
    CreateOpaPolicy  onap.policy.opa.pdp.policy-vehicle-create.yaml  vehicle  1.0.3  201
    DeployOpaPolicy  onap.policy.opa.pdp.policy-vehicle-deploy.json  vehicle
    ${URL_CONTEXT}=    Set Variable    node/vehicle
    ${DYNAMIC_URL}=    Set Variable    ${DATA_URL}${URL_CONTEXT}
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-vehicle-output.json  data
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-add.json  204  202
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.dyn-data-add-output.json  data
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-replace.json  204  202
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.dyn-data-replace-output.json  data
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-remove.json  204  202
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-vehicle-output.json  data
    ValidatePolicyResponse  onap.policy.policy.opa.pdp.decision.vehicle_input.json  200  onap.policy.policy.opa.pdp.decision.vehicle_output.json
    ValidateIncorrectPolicyNameResponse  onap.policy.policy.opa.pdp.decision.vehicle-incorect-policyname.json  400
    ValidateIncorrectPolicyFilterResponse  onap.policy.policy.opa.pdp.decision.vehicle-incorect-policyfilter.json  200
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/vehicle  202
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/vehicle  400
    ValidateGetDynamicData  ${DYNAMIC_URL}  404  onap.policy.opa.pdp.policy-resource-not-found.json  responseCode 
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-remove.json  400  400

ValidatesAbacPolicy
    CreateOpaPolicy  onap.policy.opa.pdp.policy-abac-create.yaml  abac  1.0.2  201
    DeployOpaPolicy  onap.policy.opa.pdp.policy-abac-deploy.json  abac
    ${URL_CONTEXT}=    Set Variable    node/abac
    ${DYNAMIC_URL}=    Set Variable    ${DATA_URL}${URL_CONTEXT}
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-abac-output.json  data
    ValidatePolicyResponse  onap.policy.policy.opa.pdp.decision.abac-pemit-policy.json  200  onap.policy.policy.opa.pdp.decision.abac-output.json
    ValidateIncorrectPolicyNameResponse  onap.policy.policy.opa.pdp.decision.abac-incorrect-policyname.json  400
    ValidateIncorrectPolicyFilterResponse  onap.policy.policy.opa.pdp.decision.abac-incorrect-policyfilter.json  200
    CreatePolicyDeployFailure  onap.policy.opa.pdp.policy-abac-duplicate-create.yaml  406  NOT_ACCEPTABLE
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/abac  202
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/abac  400

*** Keywords ***
PdpxGetReq
    [Documentation]     Verify the response of Health Check is Successful
    [Arguments]   ${url}  ${status}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest  ${POLICY_OPA_IP}  ${url}  200  null  ${hcauth}
    Should Be Equal As Strings    ${resp}   ${status}

CreateOpaPolicy
    [Documentation]  Create a opa policy
    [Arguments]  ${jsonfile}  ${policy_name}  ${policy_version}  ${expected_status}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    CreatePolicyWithYaml  /policy/api/v1/policytypes/onap.policies.native.opa/versions/1.0.0/policies  ${expected_status}  ${postjson}

CreatePolicyDeployFailure
    [Documentation]  Create a Failure opa policy
    [Arguments]  ${jsonfile}  ${expected_status}  ${keyword}
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.opa.pdp.policy-abac-duplicate-create.yaml
    CreateFailurePolicyWithYaml  /policy/api/v1/policytypes/onap.policies.native.opa/versions/1.0.0/policies  ${expected_status}  ${postjson}  ${keyword}

DeployOpaPolicy
    [Documentation]   Runs Policy PAP to deploy a policy
    [Arguments]  ${jsonfile}  ${policy_name}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${policyadmin}=  PolicyAdminAuth
    PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/policies  202  ${postjson}  null  ${policyadmin}
    Sleep  20sec
    ${result}=     CheckKafkaTopic    policy-notification     ${policy_name}
    Should Contain    ${result}    deployed-policies

UndeployOpaPolicy
    [Documentation]    Runs Policy PAP to undeploy a policy
    [Arguments]  ${url}  ${expected_status}
    ${policyadmin}=  PolicyAdminAuth
    PerformDeleteRequest  ${POLICY_PAP_IP}  ${url}  ${expected_status}  ${policyadmin}

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

ValidateGetDynamicData
    [Documentation]    Validating the output for the policy
    [Arguments]  ${dyn_url}  ${status}  ${jsonfile1}  ${json_key_name}
    ${expectedStatus}=    Set Variable    ${status}
    ${expected_data}=  Get file  ${CURDIR}/data/${jsonfile1}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest   ${POLICY_OPA_IP}  ${dyn_url}  ${expectedStatus}  abbrev=true  ${hcauth}
    ${response_data}=    Get From Dictionary    ${resp.json()}    ${json_key_name}
    ${expected_value}=    Evaluate    json.loads('''${expected_data}''')    json
    ${expected_output}=    Get From Dictionary    ${expected_value}    ${json_key_name}
    ${is_dict}=    Is Variable Dictionary   ${response_data}
    Run Keyword If    ${is_dict}
    ...    Should Be Equal    ${response_data}    ${expected_output}
    Run Keyword If    not ${is_dict}
    ...    Should Be Equal As Strings    ${response_data}    ${expected_output}

ValidatePatchDynamicData
    [Documentation]    Validating the output for the policy
    [Arguments]  ${dyn_url}  ${jsonfile}  ${status}  ${status1}
    ${Accepted}=    Set Variable    ${status}
    ${NoContent}=    Set Variable    ${status1}
    ${patchjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPatchRequest   ${POLICY_OPA_IP}  ${dyn_url}  ${Accepted}  ${patchjson}  abbrev=true  ${hcauth}
    IF    ${resp.status_code} == ${Accepted} or ${resp.status_code} == ${NoContent}
    Log    Status is acceptable
    ELSE
    Fail    Unexpected status code: ${resp.status_code}
    END

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

ValidateIncorrectPolicyNameResponse
    [Documentation]    Validating the incorrect name output for the policy
    [Arguments]  ${jsonfile}  ${status}
    ${expectedStatus}=    Set Variable    ${status}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPostRequest   ${POLICY_OPA_IP}  ${url}  ${expectedStatus}  ${postjson}  abbrev=true  ${hcauth}
    ${response_data}=    Get From Dictionary    ${resp.json()}    responseCode
    Should Be Equal As Strings    ${response_data}  bad_request

ValidateIncorrectPolicyFilterResponse
    [Documentation]    Validating the incorrect filter output for the policy
    [Arguments]  ${jsonfile}  ${status}
    ${expectedStatus}=    Set Variable    ${status}
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPostRequest   ${POLICY_OPA_IP}  ${url}  ${expectedStatus}  ${postjson}  abbrev=true  ${hcauth}
    ${response_data}=    Get From Dictionary    ${resp.json()}    output
    Should Be Equal As Strings   ${response_data}  None
