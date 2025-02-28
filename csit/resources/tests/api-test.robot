*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     json
Resource    common-library.robot

*** Test Cases ***

Healthcheck
    [Documentation]  Verify policy api health check
    ${resp}=  GetReq  /policy/api/v1/healthcheck
    Should Be Equal As Strings  ${resp.json()['code']}  200
    Should Be Equal As Strings  ${resp.json()['healthy']}  True
    Should Be Equal As Strings  ${resp.json()['message']}  alive

RetrievePolicyTypes
    [Documentation]  Retrieve all policy types
    FetchPolicyTypes  /policy/api/v1/policytypes  38

CreateTCAPolicyTypeV1
    [Documentation]  Create an existing policy type with modification and keeping the same version should result in error.
    CreatePolicyType  /policy/api/v1/policytypes  406  onap.policy.monitoring.tcagen2.v1.json  null  null

CreateTCAPolicyTypeV2
    [Documentation]  Create an existing policy type with modification and keeping the same version should result in error.
    CreatePolicyType  /policy/api/v1/policytypes  406  onap.policy.monitoring.tcagen2.v2.json  null  null

CreateTCAPolicyTypeV3
    [Documentation]  Create a policy type named 'onap.policies.monitoring.tcagen2' and version '3.0.0'
    CreatePolicyType  /policy/api/v1/policytypes  201  onap.policy.monitoring.tcagen2.v3.json  onap.policies.monitoring.tcagen2  3.0.0

RetrieveMonitoringPolicyTypes
    [Documentation]  Retrieve all monitoring related policy types
    FetchPolicyTypes  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2  2

CreateNewMonitoringPolicyV1
    [Documentation]  Create a policy named 'onap.restart.tca' and version '1.0.0' using specific api
    ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.json
    CreatePolicySuccessfully  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  ${postjson}  onap.restart.tca  1.0.0

CreateNewMonitoringPolicyV1Again
    [Documentation]  Create an existing policy with modification and keeping the same version should result in error.
    ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.v1_2.json
    CreatePolicy  /policy/api/v1/policies  406  ${postjson}  null  null

CreateNewMonitoringPolicyV2
    [Documentation]  Create a policy named 'onap.restart.tca' and version '2.0.0' using generic api
    ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.v2.json
    CreatePolicySuccessfully  /policy/api/v1/policies  ${postjson}  onap.restart.tca  2.0.0

CreateNodeTemplates
    [Documentation]  Create node templates in database using specific api
    ${postjson}=  Get file  ${NODETEMPLATES}/nodetemplates.metadatasets.input.tosca.json
    CreateNodeTemplate  /policy/api/v1/nodetemplates  201  ${postjson}  3

RetrievePoliciesOfType
    [Documentation]  Retrieve all policies belonging to a specific Policy Type
    FetchPolicies  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  2

RetrieveAllPolicies
    [Documentation]  Retrieve all policies
    FetchPolicies  /policy/api/v1/policies  4

RetrieveSpecificPolicy
    [Documentation]    Retrieve a policy named 'onap.restart.tca' and version '1.0.0' using generic api
    FetchPolicy  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0  onap.restart.tca

RetrieveAllNodeTemplates
    [Documentation]  Retrieve all node templates
    FetchNodeTemplates  /policy/api/v1/nodetemplates  3

RetrieveSpecificNodeTemplate
    [Documentation]    Retrieve a node template named 'apexMetadata_grpc' and version '1.2.1' using generic api
    FetchNodeTemplate  /policy/api/v1/nodetemplates/apexMetadata_grpc/versions/1.2.1  apexMetadata_grpc

DeleteSpecificNodeTemplate
    [Documentation]  Delete a node template named 'apexMetadata_adaptive' and version '2.3.1' using generic api
    DeleteReq  /policy/api/v1/nodetemplates/apexMetadata_adaptive/versions/2.3.1  200
    DeleteReq  /policy/api/v1/nodetemplates/apexMetadata_adaptive/versions/2.3.1  404

DeleteSpecificPolicy
    [Documentation]  Delete a policy named 'onap.restart.tca' and version '1.0.0' using generic api
    DeleteReq  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0  200
    DeleteReq  /policy/api/v1/policies/onap.restart.tca/versions/1.0.0  404

DeleteSpecificPolicyV2
    [Documentation]  Delete a policy named 'onap.restart.tca' and version '2.0.0' using specific api
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0  200
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies/onap.restart.tca/versions/2.0.0  404

DeleteSpecificPolicyTypeV1
    [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '1.0.0'
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0  200
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0  404

DeleteSpecificPolicyTypeV2
    [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '2.0.0'
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0  200
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/2.0.0  404

DeleteSpecificPolicyTypeV3
    [Documentation]  Delete a policy type named 'onap.policies.monitoring.tcagen2' and version '3.0.0'
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/3.0.0  200
    DeleteReq  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/3.0.0  404

Metrics
    [Documentation]  Verify policy-api is exporting prometheus metrics
    ${auth}=  PolicyAdminAuth
    ${resp}=  GetMetrics  ${POLICY_API_IP}  ${auth}  /policy/api/v1/
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/healthcheck"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/policytypes"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/policies"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/policies/{policyId}/versions/{policyVersion}"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="GET",outcome="SUCCESS",status="200",uri="/policytypes/{policyTypeId}/versions/{policyTypeVersion}/policies"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/policytypes/{policyTypeId}/versions/{policyTypeVersion}/policies"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="POST",outcome="SUCCESS",status="201",uri="/policytypes"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="SUCCESS",status="200",uri="/policies/{policyId}/versions/{policyVersion}"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="SUCCESS",status="200",uri="/policytypes/{policyTypeId}/versions/{versionId}"} 3
    Should Contain  ${resp.text}  http_server_requests_seconds_count{error="none",exception="none",method="DELETE",outcome="SUCCESS",status="200",uri="/policytypes/{policyTypeId}/versions/{policyTypeVersion}/policies/{policyId}/versions/{policyVersion}"} 1
    Should Contain  ${resp.text}  http_server_requests_seconds_sum
    Should Contain  ${resp.text}  http_server_requests_seconds_max
    Should Contain  ${resp.text}  spring_data_repository_invocations_seconds_count
    Should Contain  ${resp.text}  spring_data_repository_invocations_seconds_sum
    Should Contain  ${resp.text}  spring_data_repository_invocations_seconds_max
    Should Contain  ${resp.text}  jvm_threads_live_threads

*** Keywords ***

GetReq
    [Arguments]  ${url}
    ${auth}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${POLICY_API_IP}  ${url}  200  null  ${auth}
    RETURN  ${resp}

DeleteReq
    [Arguments]  ${url}  ${expectedstatus}
    ${auth}=  PolicyAdminAuth
    ${resp}=  PerformDeleteRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${auth}
    RETURN  ${resp}

CreatePolicyType
    [Arguments]  ${url}  ${expectedstatus}  ${jsonfile}  ${policytypename}  ${policytypeversion}
    [Documentation]  Create the specific policy type
    ${postjson}=  Get file  ${CURDIR}/data/${jsonfile}
    ${auth}=  PolicyAdminAuth
    ${resp}=  PerformPostRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${postjson}  null  ${auth}
    Run Keyword If  ${expectedstatus}==200  List Should Contain Value  ${resp.json()['policy_types']}  ${policytypename}
    Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['policy_types']['${policytypename}']['version']}  ${policytypeversion}

FetchPolicyTypes
    [Arguments]  ${url}  ${expectedLength}
    [Documentation]  Fetch all policy types
    ${resp}=  GetReq  ${url}
    Length Should Be  ${resp.json()['policy_types']}  ${expectedLength}

FetchPolicy
    [Arguments]  ${url}  ${keyword}
    [Documentation]  Fetch the specific policy
    ${resp}=  GetReq  ${url}
    Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${keyword}

FetchPolicies
    [Arguments]  ${url}  ${expectedLength}
    [Documentation]  Fetch all policies
    ${resp}=  GetReq  ${url}
    Length Should Be  ${resp.json()['topology_template']['policies']}  ${expectedLength}

FetchNodeTemplates
    [Arguments]  ${url}  ${expectedLength}
    [Documentation]  Fetch all node templates
    ${resp}=  GetReq  ${url}
    Length Should Be  ${resp.json()}  ${expectedLength}

FetchNodeTemplate
    [Arguments]  ${url}  ${keyword}
    [Documentation]  Fetch the specific node template
    ${resp}=  GetReq  ${url}
    Dictionary Should Contain Value  ${resp.json()[0]}  ${keyword}
