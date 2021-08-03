*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json

*** Test Cases ***
LoadPolicy
    [Documentation]  Create a policy named 'onap.restart.tca' and version '1.0.0' using specific api
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  200  vCPE.policy.monitoring.input.tosca.json  onap.restart.tca  1.0.0

Healthcheck
    [Documentation]  Verify policy pap health check
    ${resp}=  PeformGetRequest  /policy/pap/v1/healthcheck  200  null
    Should Be Equal As Strings  ${resp.json()['code']}  200

Statistics
    [Documentation]  Verify policy pap statistics
    ${resp}=  PeformGetRequest  /policy/pap/v1/statistics  200  null
    Should Be Equal As Strings  ${resp.json()['code']}  200

AddPdpGroup
    [Documentation]  Add a new PdpGroup named 'testGroup' in the policy database
    PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/groups/batch  200  create.group.request.json  ${CURDIR}/data

ActivatePdpGroup
    [Documentation]  Change the state of PdpGroup named 'testGroup' to ACTIVE
    PerformPutRequest  /policy/pap/v1/pdps/groups/testGroup  200  ACTIVE

QueryPdpGroupsAfterActivation
    [Documentation]  Verify PdpGroups after activation
    QueryPdpGroups  2  0

DeployPdpGroups
    [Documentation]  Deploy policies in PdpGroups
    PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/deployments/batch  202  deploy.group.request.json  ${CURDIR}/data

QueryPdpGroupsAfterDeploy
    [Documentation]  Verify PdpGroups after undeploy
    QueryPdpGroups  2  1

QueryPolicyAuditAfterDeploy
    [Documentation]  Verify policy audit record after deploy
    QueryPolicyAudit  /policy/pap/v1/policies/audit  200  DEPLOYMENT

UndeployPolicy
    [Documentation]  Undeploy a policy named 'onap.restart.tca' from PdpGroups
    PeformDeleteRequest  /policy/pap/v1/pdps/policies/onap.restart.tca  202

QueryPdpGroupsAfterUndeploy
    [Documentation]  Verify PdpGroups after undeploy
    QueryPdpGroups  2  0

QueryPolicyAuditAfterUnDeploy
    [Documentation]  Verify policy audit record after undeploy
    QueryPolicyAudit  /policy/pap/v1/policies/audit  200  UNDEPLOYMENT

DeactivatePdpGroup
    [Documentation]  Change the state of PdpGroup named 'testGroup' to PASSIVE
    PerformPutRequest  /policy/pap/v1/pdps/groups/testGroup  200  PASSIVE

DeletePdpGroups
    [Documentation]  Delete the PdpGroup named 'testGroup' from policy database
    PeformDeleteRequest  /policy/pap/v1/pdps/groups/testGroup  200

QueryPdpGroupsAfterDelete
    [Documentation]    Verify PdpGroups after delete
    QueryPdpGroups  1  0

*** Keywords ***

CreatePolicy
    [Arguments]  ${url}  ${expectedstatus}  ${jsonfile}  ${policyname}  ${policyversion}
    [Documentation]  Create the specific policy
    ${resp}=  PerformPostRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${jsonfile}  ${DATA}
    Run Keyword If  ${expectedstatus}==200  Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${policyname}
    Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['topology_template']['policies'][0]['${policyname}']['version']}  ${policyversion}

QueryPdpGroups
    [Arguments]  ${groupsLength}  ${policiesLength}
    ${resp}=  PeformGetRequest  /policy/pap/v1/pdps  200  null
    Length Should Be  ${resp.json()['groups']}  ${groupsLength}
    Should Be Equal As Strings  ${resp.json()['groups'][0]['name']}  defaultGroup
    Should Be Equal As Strings  ${resp.json()['groups'][0]['pdpGroupState']}  ACTIVE
    Run Keyword If  ${groupsLength}>1  Should Be Equal As Strings  ${resp.json()['groups'][1]['name']}  testGroup
    Run Keyword If  ${groupsLength}>1  Should Be Equal As Strings  ${resp.json()['groups'][1]['pdpGroupState']}  ACTIVE
    Run Keyword If  ${groupsLength}>1  Length Should Be  ${resp.json()['groups'][1]['pdpSubgroups'][0]['policies']}  ${policiesLength}

QueryPolicyAudit
    [Arguments]  ${url}  ${expectedstatus}  ${expectedAction}
    ${resp}=  PeformGetRequest  ${url}  ${expectedstatus}  recordCount=1
    Should Be Equal As Strings    ${resp.json()[0]['pdpGroup']}  testGroup
    Should Be Equal As Strings    ${resp.json()[0]['pdpType']}  pdpTypeA
    Should Be Equal As Strings    ${resp.json()[0]['policy']['name']}  onap.restart.tca
    Should Be Equal As Strings    ${resp.json()[0]['policy']['version']}  1.0.0
    Should Be Equal As Strings    ${resp.json()[0]['action']}  ${expectedAction}
    Should Be Equal As Strings    ${resp.json()[0]['user']}  healthcheck

PerformPostRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${jsonfile}  ${filepath}
    ${auth}=  Create List  healthcheck  zb!XztG34
    ${postjson}=  Get file  ${filepath}/${jsonfile}
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  POST On Session  policy  ${url}  data=${postjson}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformPutRequest
    [Arguments]  ${url}  ${expectedstatus}  ${state}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${POLICY_PAP_IP}:6969
    ${session}=  Create Session  policy  https://${POLICY_PAP_IP}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  PUT On Session  policy  ${url}  params=state=${state}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PeformGetRequest
    [Arguments]  ${url}  ${expectedstatus}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${POLICY_PAP_IP}:6969
    ${session}=  Create Session  policy  https://${POLICY_PAP_IP}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  GET On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PeformDeleteRequest
    [Arguments]  ${url}  ${expectedstatus}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${POLICY_PAP_IP}:6969
    ${session}=  Create Session  policy  https://${POLICY_PAP_IP}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  DELETE On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
