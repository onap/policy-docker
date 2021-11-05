*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json

*** Keywords ***

PolicyAdminAuth
    ${policyadmin}=   Create list   policyadmin    zb!XztG34
    [return]  ${policyadmin}

HealthCheckAuth
    ${healthcheck}=   Create list   healthcheck    zb!XztG34
    [return]  ${healthcheck}

PerformPostRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${postjson}  ${params}  ${auth}
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  POST On Session  policy  ${url}  data=${postjson}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformPutRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${params}  ${auth}
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  PUT On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformGetRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${params}  ${auth}
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  GET On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformDeleteRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${auth}
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  DELETE On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}

CreatePolicy
    [Arguments]  ${url}  ${expectedstatus}  ${postjson}  ${policyname}  ${policyversion}
    [Documentation]  Create the specific policy
    ${policyadmin}=  PolicyAdminAuth
    ${resp}=  PerformPostRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${postjson}  null  ${policyadmin}
    Run Keyword If  ${expectedstatus}==200  Dictionary Should Contain Key  ${resp.json()['topology_template']['policies'][0]}  ${policyname}
    Run Keyword If  ${expectedstatus}==200  Should Be Equal As Strings  ${resp.json()['topology_template']['policies'][0]['${policyname}']['version']}  ${policyversion}

QueryPdpGroups
    [Documentation]    Verify pdp group query - supports upto 2 groups
    [Arguments]  ${groupsLength}  ${group1Name}  ${group1State}  ${policiesLengthInGroup1}  ${group2Name}  ${group2State}  ${policiesLengthInGroup2}
    ${policyadmin}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps  200  null  ${policyadmin}
    Length Should Be  ${resp.json()['groups']}  ${groupsLength}
    Should Be Equal As Strings  ${resp.json()['groups'][0]['name']}  ${group1Name}
    Should Be Equal As Strings  ${resp.json()['groups'][0]['pdpGroupState']}  ${group1State}
    Length Should Be  ${resp.json()['groups'][0]['pdpSubgroups'][0]['policies']}  ${policiesLengthInGroup1}
    Run Keyword If  ${groupsLength}>1  Should Be Equal As Strings  ${resp.json()['groups'][1]['name']}  ${group2Name}
    Run Keyword If  ${groupsLength}>1  Should Be Equal As Strings  ${resp.json()['groups'][1]['pdpGroupState']}  ${group2State}
    Run Keyword If  ${groupsLength}>1  Length Should Be  ${resp.json()['groups'][1]['pdpSubgroups'][0]['policies']}  ${policiesLengthInGroup2}

QueryPolicyAudit
    [Arguments]  ${url}  ${expectedstatus}  ${pdpGroup}  ${pdpType}  ${policyName}  ${expectedAction}
    ${policyadmin}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  ${url}  ${expectedstatus}  recordCount=1   ${policyadmin}
    Should Be Equal As Strings    ${resp.json()[0]['pdpGroup']}  ${pdpGroup}
    Should Be Equal As Strings    ${resp.json()[0]['pdpType']}  ${pdpType}
    Should Be Equal As Strings    ${resp.json()[0]['policy']['name']}  ${policyName}
    Should Be Equal As Strings    ${resp.json()[0]['policy']['version']}  1.0.0
    Should Be Equal As Strings    ${resp.json()[0]['action']}  ${expectedAction}
    Should Be Equal As Strings    ${resp.json()[0]['user']}  policyadmin

QueryPolicyStatus
    [Documentation]    Verify policy deployment status
    [Arguments]  ${policyName}  ${pdpGroup}  ${pdpType}  ${pdpName}  ${policyTypeName}
    ${policyadmin}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  /policy/pap/v1/policies/status  200  null   ${policyadmin}
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

