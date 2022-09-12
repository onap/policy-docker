*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json


*** Keywords ***

CreatePolicy
    [Arguments]  ${url}  ${expectedstatus}  ${postjson}  ${policyname}  ${policyversion}
    [Documentation]  Create the specific policy
    ${resp}=  PerformPostRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${postjson}  null
    Run Keyword If  ${expectedstatus}==200  Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${policyname}
    Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['topology_template']['policies'][0]['${policyname}']['version']}  ${policyversion}

QueryPdpGroups
    [Documentation]    Verify pdp group query - supports upto 2 groups
    [Arguments]  ${groupsLength}  ${group1Name}  ${group1State}  ${policiesLengthInGroup1}  ${group2Name}  ${group2State}  ${policiesLengthInGroup2}
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps  200  null
    Length Should Be  ${resp.json()['groups']}  ${groupsLength}
    Should Be Equal As Strings  ${resp.json()['groups'][0]['name']}  ${group1Name}
    Should Be Equal As Strings  ${resp.json()['groups'][0]['pdpGroupState']}  ${group1State}
    Length Should Be  ${resp.json()['groups'][0]['pdpSubgroups'][0]['policies']}  ${policiesLengthInGroup1}
    Run Keyword If  ${groupsLength}>1  Should Be Equal As Strings  ${resp.json()['groups'][1]['name']}  ${group2Name}
    Run Keyword If  ${groupsLength}>1  Should Be Equal As Strings  ${resp.json()['groups'][1]['pdpGroupState']}  ${group2State}
    Run Keyword If  ${groupsLength}>1  Length Should Be  ${resp.json()['groups'][1]['pdpSubgroups'][0]['policies']}  ${policiesLengthInGroup2}

QueryPolicyAudit
    [Arguments]  ${url}  ${expectedstatus}  ${pdpGroup}  ${pdpType}  ${policyName}  ${expectedAction}
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  ${url}  ${expectedstatus}  recordCount=1
    Should Be Equal As Strings    ${resp.json()[0]['pdpGroup']}  ${pdpGroup}
    Should Be Equal As Strings    ${resp.json()[0]['pdpType']}  ${pdpType}
    Should Be Equal As Strings    ${resp.json()[0]['policy']['name']}  ${policyName}
    Should Be Equal As Strings    ${resp.json()[0]['policy']['version']}  1.0.0
    Should Be Equal As Strings    ${resp.json()[0]['action']}  ${expectedAction}
    Should Be Equal As Strings    ${resp.json()[0]['user']}  healthcheck

QueryPolicyStatus
     [Documentation]    Verify policy deployment status
     [Arguments]  ${policyName}  ${pdpGroup}  ${pdpType}  ${pdpName}  ${policyTypeName}
     ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/policies/status  200  null
     FOR    ${responseEntry}    IN    @{resp.json()}
     Exit For Loop IF      '${responseEntry['policy']['name']}'=='${policyName}'
     END
     Should Be Equal As Strings    ${resp.status_code}     200
     Should Be Equal As Strings    ${responseEntry['pdpGroup']}  ${pdpGroup}
     Should Be Equal As Strings    ${responseEntry['pdpType']}  ${pdpType}
     Should Be Equal As Strings    ${responseEntry['pdpId']}  ${pdpName}
     Should Be Equal As Strings    ${responseEntry['policy']['name']}  ${policyName}
     Should Be Equal As Strings    ${responseEntry['policy']['version']}  1.0.0
     Should Be Equal As Strings    ${responseEntry['policyType']['name']}  ${policyTypeName}
     Should Be Equal As Strings    ${responseEntry['policyType']['version']}  1.0.0
     Should Be Equal As Strings    ${responseEntry['deploy']}  True
     Should Be Equal As Strings    ${responseEntry['state']}  SUCCESS

PerformPostRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${postjson}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session http://${hostname}:6969
    ${session}=  Create Session  policy  http://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  POST On Session  policy  ${url}  data=${postjson}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformPutRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session http://${hostname}:6969
    ${session}=  Create Session  policy  http://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  PUT On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformGetRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session http://${hostname}:6969
    ${session}=  Create Session  policy  http://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  GET On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformDeleteRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session http://${hostname}:6969
    ${session}=  Create Session  policy  http://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  DELETE On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
