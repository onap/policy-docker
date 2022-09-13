*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json

*** Test Cases ***

Healthcheck
     [Documentation]  Verify policy api health check
     ${resp}=  PeformGetRequest  /policy/api/v1/healthcheck  200
     Should Be Equal As Strings  ${resp.json()['code']}  200

Statistics
     [Documentation]  Verify policy api statistics
     ${resp}=  PeformGetRequest  /policy/api/v1/statistics  200
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
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  200  vCPE.policy.monitoring.input.tosca.json  onap.restart.tca  1.0.0

CreateNewMonitoringPolicyV1Again
     [Documentation]  Create an existing policy with modification and keeping the same version should result in error.
     CreatePolicy  /policy/api/v1/policies  406  vCPE.policy.monitoring.input.tosca.v1_2.json  null  null

CreateNewMonitoringPolicyV2
     [Documentation]  Create a policy named 'onap.restart.tca' and version '2.0.0' using generic api
     CreatePolicy  /policy/api/v1/policies  200  vCPE.policy.monitoring.input.tosca.v2.json  onap.restart.tca  2.0.0

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
     PeformDeleteRequest  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0

DeleteSpecificPolicyV2
     [Documentation]  Delete a policy named 'onap.restart.tca' and version '2.0.0' using specific api
     PeformDeleteRequest  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0

DeleteSpecificPolicyTypeV1
     [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '1.0.0'
     PeformDeleteRequest  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0

DeleteSpecificPolicyTypeV2
     [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '2.0.0'
     PeformDeleteRequest  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0

*** Keywords ***

CreatePolicyType
     [Arguments]  ${url}  ${expectedstatus}  ${jsonfile}  ${policytypename}  ${policytypeversion}
     [Documentation]  Create the specific policy type
     ${resp}=  PerformCreateRequest  ${url}  ${expectedstatus}  ${jsonfile}  ${CURDIR}/data
     Run Keyword If  ${expectedstatus}==200  List Should Contain Value  ${resp.json()['policy_types']}  ${policytypename}
     Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['policy_types']['${policytypename}']['version']}  ${policytypeversion}

FetchPolicyTypes
     [Arguments]  ${url}  ${expectedLength}
     [Documentation]  Fetch all policy types
     ${resp}=  PeformGetRequest  ${url}  200
     Length Should Be  ${resp.json()['policy_types']}  ${expectedLength}

CreatePolicy
     [Arguments]  ${url}  ${expectedstatus}  ${jsonfile}  ${policyname}  ${policyversion}
     [Documentation]  Create the specific policy
     ${resp}=  PerformCreateRequest  ${url}  ${expectedstatus}  ${jsonfile}  ${DATA}
     Run Keyword If  ${expectedstatus}==200  Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${policyname}
     Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['topology_template']['policies'][0]['${policyname}']['version']}  ${policyversion}

FetchPolicy
     [Arguments]  ${url}  ${keyword}
     [Documentation]  Fetch the specific policy
     ${resp}=  PeformGetRequest  ${url}  200
     Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${keyword}

FetchPolicies
     [Arguments]  ${url}  ${expectedLength}
     [Documentation]  Fetch all policies
     ${resp}=  PeformGetRequest  ${url}  200
     Length Should Be  ${resp.json()['topology_template']['policies']}  ${expectedLength}

PerformCreateRequest
     [Arguments]  ${url}  ${expectedstatus}  ${jsonfile}  ${filepath}
     ${auth}=  Create List  healthcheck  zb!XztG34
     ${postjson}=  Get file  ${filepath}/${jsonfile}
     Log  Creating session http://${POLICY_API_IP}:6969
     ${session}=  Create Session  policy  http://${POLICY_API_IP}:6969  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
     ${resp}=  POST On Session  policy  ${url}  data=${postjson}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}

PeformGetRequest
     [Arguments]  ${url}  ${expectedstatus}
     ${auth}=  Create List  healthcheck  zb!XztG34
     Log  Creating session http://${POLICY_API_IP}:6969
     ${session}=  Create Session  policy  http://${POLICY_API_IP}:6969  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
     ${resp}=  GET On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}

PeformDeleteRequest
     [Arguments]  ${url}
     ${auth}=  Create List  healthcheck  zb!XztG34
     Log  Creating session http://${POLICY_API_IP}:6969
     ${session}=  Create Session  policy  http://${POLICY_API_IP}:6969  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
     ${resp}=  DELETE On Session  policy  ${url}  headers=${headers}  expected_status=200
     Log  Received response from policy ${resp.text}
     ${resp}=  DELETE On Session  policy  ${url}  headers=${headers}  expected_status=404
