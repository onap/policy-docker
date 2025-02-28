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
${DATA_URL}    /policy/pdpo/v1/data/

*** Test Cases ***
Healthcheck
    [Documentation]    Verify OPA PDP health check
    PdpxGetReq  ${OPA_PDP_HOST}  <Response [200]>

ValidateDataBeforePolicyDeployment
    ValidateGetDynamicData  ${DATA_URL}  200  onap.policy.opa.pdp.data-empty.json  data

ValidatesZonePolicy
    CreateOpaPolicy  onap.policy.opa.pdp.new-zone.yaml  zoneB  1.0.3  201
    DeployOpaPolicy  onap.policy.opa.pdp.new-zone-deploy.json  zoneB
    ${URL_CONTEXT}=    Set Variable    node/zoneB/zone
    ${DYNAMIC_URL}=    Set Variable    ${DATA_URL}${URL_CONTEXT}
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-zone-expected.json  data
    ValidatePolicyResponse  onap.policy.policy.opa.pdp.decision.zone-policy-input.json  200  onap.policy.opa.pdp.decision.zone-policy-output.json
    ValidateIncorrectPolicyNameResponse  onap.policy.opa.pdp.decision.zone-incorrect-policyname.json  400
    ValidateIncorrectPolicyFilterResponse  onap.policy.opa.pdp.decision.zone-incorrect-policyfilter.json  200
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/zoneB  202
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/zoneB  400

ValidatesVehiclePolicy
    CreateOpaPolicy  onap.policy.opa.pdp.vehicle-policy.yaml  vehicle  1.0.3  201
    DeployOpaPolicy  onap.policy.opa.pdp.vehicle-deploy-policy.json  vehicle
    ${URL_CONTEXT}=    Set Variable    node/vehicle
    ${DYNAMIC_URL}=    Set Variable    ${DATA_URL}${URL_CONTEXT}
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-vehicle-expected.json  data
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-add.json  204
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.dyn-data-add-expected.json  data
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-replace.json  204
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.dyn-data-replace-expected.json  data
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-remove.json  204
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-vehicle-expected.json  data
    ValidatePolicyResponse  onap.policy.policy.opa.pdp.decision.vehicle_input_permit.json  200  onap.policy.policy.opa.pdp.decision.vehicle_output_permit_response.json
    ValidateIncorrectPolicyNameResponse  onap.policy.policy.opa.pdp.decision.vehicle-incorect-policyname.json  400
    ValidateIncorrectPolicyFilterResponse  onap.policy.policy.opa.pdp.decision.vehicle-incorect-policyfilter.json  200
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/vehicle  202
    UndeployOpaPolicy  /policy/pap/v1/pdps/policies/vehicle  400
    ValidateGetDynamicData  ${DYNAMIC_URL}  404  onap.policy.opa.pdp.policy-resource-not-found.json  responseCode 
    ValidatePatchDynamicData  ${DYNAMIC_URL}  onap.policy.opa.pdp.dyn-data-remove.json  400

ValidatesAbacPolicy
    CreateOpaPolicy  onap.policy.opa.pdp.opa-policy.yaml  abac  1.0.2  201
    DeployOpaPolicy  onap.policy.opa.pdp.opa-deploy.json  abac
    ${URL_CONTEXT}=    Set Variable    node/abac
    ${DYNAMIC_URL}=    Set Variable    ${DATA_URL}${URL_CONTEXT}
    ValidateGetDynamicData  ${DYNAMIC_URL}  200  onap.policy.opa.pdp.policy-abac-expected.json  data
    ValidatePolicyResponse  onap.policy.policy.opa.pdp.decision.abac-pemit-policy.json  200  onap.policy.policy.opa.pdp.decision.abac_response.json
    ValidateIncorrectPolicyNameResponse  onap.policy.policy.opa.pdp.decision.abac-incorrect-policyname.json  400
    ValidateIncorrectPolicyFilterResponse  onap.policy.policy.opa.pdp.decision.abac-incorrect-policyfilter.json  200
    CreateFailureDeployPolicy  onap.policy.policy.opa.pdp.decision.opa-policy-duplicate.yaml  406  NOT_ACCEPTABLE
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

CreateFailureDeployPolicy
    [Documentation]  Create a Failure opa policy
    [Arguments]  ${jsonfile}  ${expected_status}  ${keyword}
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.policy.opa.pdp.decision.opa-policy-duplicate.yaml
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
    [Arguments]  ${dyn_url}  ${jsonfile}  ${status}
    ${expectedStatus}=    Set Variable    ${status}
    ${patchjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=    PerformPatchRequest   ${POLICY_OPA_IP}  ${dyn_url}  ${expectedStatus}  ${patchjson}  abbrev=true  ${hcauth}
    Should Be Equal As Integers    ${resp.status_code}    ${expectedStatus}

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

Is Variable Dictionary
    [Arguments]  ${variable}
    ${is_dict}=  Set Variable    False
    ${status}    ${result}=    Run Keyword And Ignore Error    Should Contain    ${variable}    data
    Run Keyword If   '${status}'
    ...    Set Variable    ${is_dict}=    True  # It means it's a dictionary.
    RETURN    ${is_dict}
