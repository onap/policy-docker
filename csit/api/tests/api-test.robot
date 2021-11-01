*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Resource    ${CURDIR}/../../api-pap-common.robot

*** Test Cases ***

Healthcheck
     [Documentation]  Verify policy api health check
     ${resp}=  PapApiGetRequest  ${POLICY_API_IP}  /policy/api/v1/healthcheck  200  null
     Should Be Equal As Strings  ${resp.json()['code']}  200

Metrics
    [Documentation]  Verify policy-api is exporting prometheus metrics
    ${resp}=  PapApiGetRequest  ${POLICY_API_IP}  /metrics  200  null
    Should Contain  ${resp.text}  jvm_threads_current

Statistics
     [Documentation]  Verify policy api statistics
     ${resp}=  PapApiGetRequest  ${POLICY_API_IP}  /policy/api/v1/statistics  200  null
     Should Be Equal As Strings  ${resp.json()['code']}  200

RetrievePolicyTypes
     [Documentation]  Retrieve all policy types
     FetchPolicyTypes  /policy/api/v1/policytypes  37

CreateTCAPolicyTypeV1
     [Documentation]  Create an existing policy type with modification and keeping the same version should result in error.
     CreatePolicyType  /policy/api/v1/policytypes  406  onap.policy.monitoring.tcagen2.v1.json  null  null

CreateTCAPolicyTypeV2
     [Documentation]  Create a policy type named 'onap.policies.monitoring.tcagen2' and version '2.0.0'
     CreatePolicyType  /policy/api/v1/policytypes  200  onap.policy.monitoring.tcagen2.v2.json  onap.policies.monitoring.tcagen2  2.0.0

RetrieveMonitoringPolicyTypes
     [Documentation]  Retrieve all monitoring related policy types
     FetchPolicyTypes  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2  2

CreateNewMonitoringPolicyV1
     [Documentation]  Create a policy named 'onap.restart.tca' and version '1.0.0' using specific api
     ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  200  ${postjson}  onap.restart.tca  1.0.0

CreateNewMonitoringPolicyV1Again
     [Documentation]  Create an existing policy with modification and keeping the same version should result in error.
     ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.v1_2.json
     CreatePolicy  /policy/api/v1/policies  406  ${postjson}  null  null

CreateNewMonitoringPolicyV2
     [Documentation]  Create a policy named 'onap.restart.tca' and version '2.0.0' using generic api
     ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.v2.json
     CreatePolicy  /policy/api/v1/policies  200  ${postjson}  onap.restart.tca  2.0.0

RetrievePoliciesOfType
     [Documentation]  Retrieve all policies belonging to a specific Policy Type
     FetchPolicies  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  2

RetrieveAllPolicies
     [Documentation]  Retrieve all policies
     FetchPolicies  /policy/api/v1/policies  3

RetrieveSpecificPolicy
     [Documentation]    Retrieve a policy named 'onap.restart.tca' and version '1.0.0' using generic api
     FetchPolicy  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0  onap.restart.tca

DeleteSpecificPolicy
     [Documentation]  Delete a policy named 'onap.restart.tca' and version '1.0.0' using generic api
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0  200
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0  404

DeleteSpecificPolicyV2
     [Documentation]  Delete a policy named 'onap.restart.tca' and version '2.0.0' using specific api
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0  200
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0  404

DeleteSpecificPolicyTypeV1
     [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '1.0.0'
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0  200
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0  404

DeleteSpecificPolicyTypeV2
     [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '2.0.0'
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0  200
     PapApiDeleteRequest  ${POLICY_API_IP}  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0  404

*** Keywords ***

CreatePolicyType
     [Arguments]  ${url}  ${expectedstatus}  ${jsonfile}  ${policytypename}  ${policytypeversion}
     [Documentation]  Create the specific policy type
     ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
     ${resp}=  PapApiPostRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${postjson}  null
     Run Keyword If  ${expectedstatus}==200  List Should Contain Value  ${resp.json()['policy_types']}  ${policytypename}
     Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['policy_types']['${policytypename}']['version']}  ${policytypeversion}

FetchPolicyTypes
     [Arguments]  ${url}  ${expectedLength}
     [Documentation]  Fetch all policy types
     ${resp}=  PapApiGetRequest  ${POLICY_API_IP}  ${url}  200  null
     Length Should Be  ${resp.json()['policy_types']}  ${expectedLength}

FetchPolicy
     [Arguments]  ${url}  ${keyword}
     [Documentation]  Fetch the specific policy
     ${resp}=  PapApiGetRequest  ${POLICY_API_IP}  ${url}  200  null
     Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${keyword}

FetchPolicies
     [Arguments]  ${url}  ${expectedLength}
     [Documentation]  Fetch all policies
     ${resp}=  PapApiGetRequest  ${POLICY_API_IP}  ${url}  200  null
     Length Should Be  ${resp.json()['topology_template']['policies']}  ${expectedLength}
