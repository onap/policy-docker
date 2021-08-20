*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json
Resource    ${CURDIR}/../../common-library.robot

*** Test Cases ***
LoadPolicy
    [Documentation]  Create a policy named 'onap.restart.tca' and version '1.0.0' using specific api
    ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.json
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  200  ${postjson}  onap.restart.tca  1.0.0

Healthcheck
    [Documentation]  Verify policy pap health check
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/healthcheck  200  null
    Should Be Equal As Strings  ${resp.json()['code']}  200

Metrics
    [Documentation]  Verify policy pap is exporting prometheus metrics
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /metrics  200  null
    Should Contain  ${resp.text}  jvm_threads_current

Statistics
    [Documentation]  Verify policy pap statistics
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/statistics  200  null
    Should Be Equal As Strings  ${resp.json()['code']}  200

AddPdpGroup
    [Documentation]  Add a new PdpGroup named 'testGroup' in the policy database
    ${postjson}=  Get file  ${CURDIR}/data/create.group.request.json
    PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/groups/batch  200  ${postjson}  null

QueryPdpGroupsBeforeActivation
    [Documentation]  Verify PdpGroups before activation
    QueryPdpGroups  2  defaultGroup  ACTIVE  0  testGroup  PASSIVE  0

ActivatePdpGroup
    [Documentation]  Change the state of PdpGroup named 'testGroup' to ACTIVE
    PerformPutRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/groups/testGroup  200  state=ACTIVE

QueryPdpGroupsAfterActivation
    [Documentation]  Verify PdpGroups after activation
    QueryPdpGroups  2  defaultGroup  ACTIVE  0  testGroup  ACTIVE  0

DeployPdpGroups
    [Documentation]  Deploy policies in PdpGroups
    ${postjson}=  Get file  ${CURDIR}/data/deploy.group.request.json
    PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/deployments/batch  202  ${postjson}  null

QueryPdpGroupsAfterDeploy
    [Documentation]  Verify PdpGroups after undeploy
    QueryPdpGroups  2  defaultGroup  ACTIVE  0  testGroup  ACTIVE  1

QueryPolicyAuditAfterDeploy
    [Documentation]  Verify policy audit record after deploy
    QueryPolicyAudit  /policy/pap/v1/policies/audit  200  testGroup  pdpTypeA  onap.restart.tca  DEPLOYMENT

UndeployPolicy
    [Documentation]  Undeploy a policy named 'onap.restart.tca' from PdpGroups
    PerformDeleteRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/policies/onap.restart.tca  202

QueryPdpGroupsAfterUndeploy
    [Documentation]  Verify PdpGroups after undeploy
    QueryPdpGroups  2  defaultGroup  ACTIVE  0  testGroup  ACTIVE  0

QueryPolicyAuditAfterUnDeploy
    [Documentation]  Verify policy audit record after undeploy
    QueryPolicyAudit  /policy/pap/v1/policies/audit  200  testGroup  pdpTypeA  onap.restart.tca  UNDEPLOYMENT

DeactivatePdpGroup
    [Documentation]  Change the state of PdpGroup named 'testGroup' to PASSIVE
    PerformPutRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/groups/testGroup  200  state=PASSIVE

DeletePdpGroups
    [Documentation]  Delete the PdpGroup named 'testGroup' from policy database
    PerformDeleteRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/groups/testGroup  200

QueryPdpGroupsAfterDelete
    [Documentation]    Verify PdpGroups after delete
    QueryPdpGroups  1  defaultGroup  ACTIVE  0  null  null  null
