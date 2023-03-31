*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json

*** Keywords ***

PolicyAdminAuth
    ${policyadmin}=   Create list   policyadmin    zb!XztG34
    [return]  ${policyadmin}

PerformPostRequest
    [Arguments]  ${domain}  ${url}  ${expectedstatus}  ${postjson}  ${params}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  policy  http://${domain}  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  POST On Session  policy  ${url}  data=${postjson}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformPutRequest
    [Arguments]  ${domain}  ${url}  ${expectedstatus}  ${params}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  policy  http://${domain}  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  PUT On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformGetRequest
    [Arguments]  ${domain}  ${url}  ${expectedstatus}  ${params}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  policy  http://${domain}  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  GET On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformDeleteRequest
    [Arguments]  ${domain}  ${url}  ${expectedstatus}  ${auth}
    Log  Creating session http://${domain}
    ${session}=  Create Session  policy  http://${domain}  auth=${auth}
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

CreateNodeTemplate
    [Arguments]  ${url}  ${expectedstatus}  ${postjson}  ${nodeTemplateListLength}
    [Documentation]  Create the node templates
    ${policyadmin}=  PolicyAdminAuth
    ${resp}=  PerformPostRequest  ${POLICY_API_IP}  ${url}  ${expectedstatus}  ${postjson}  \  ${policyadmin}
    Run Keyword If  ${expectedstatus}==200  Length Should Be  ${resp.json()['topology_template']['node_templates']}  ${nodeTemplateListLength}


QueryPdpGroups
    [Documentation]    Verify pdp group query - suphosts upto 2 groups
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
    ${resp}=  PerformGetRequest  ${POLICY_PAP_IP}  ${url}  ${expectedstatus}  recordCount=2   ${policyadmin}
    Log  Received response from queryPolicyAudit ${resp.text}
    FOR    ${responseEntry}    IN    @{resp.json()}
    Exit For Loop IF      '${responseEntry['policy']['name']}'=='${policyName}'
    END
    Should Be Equal As Strings    ${responseEntry['pdpGroup']}  ${pdpGroup}
    Should Be Equal As Strings    ${responseEntry['pdpType']}  ${pdpType}
    Should Be Equal As Strings    ${responseEntry['policy']['name']}  ${policyName}
    Should Be Equal As Strings    ${responseEntry['policy']['version']}  1.0.0
    Should Be Equal As Strings    ${responseEntry['action']}  ${expectedAction}
    Should Be Equal As Strings    ${responseEntry['user']}  policyadmin

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
    Should Be Equal As Strings    ${responseEntry['policy']['name']}  ${policyName}
    Should Be Equal As Strings    ${responseEntry['policy']['version']}  1.0.0
    Should Be Equal As Strings    ${responseEntry['policyType']['name']}  ${policyTypeName}
    Should Be Equal As Strings    ${responseEntry['policyType']['version']}  1.0.0
    Should Be Equal As Strings    ${responseEntry['deploy']}  True
    Should Be Equal As Strings    ${responseEntry['state']}  SUCCESS

GetMetrics
    [Arguments]  ${domain}  ${auth}  ${context_path}
    Log  Creating session http://${domain}
    ${session}=  Create Session  policy  http://${domain}  auth=${auth}
    ${resp}=  GET On Session  policy  ${context_path}metrics  expected_status=200
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

QueryPrometheus
    [Arguments]  ${query}
    ${params}=  Create Dictionary  query=${query}
    ${resp}=  GET  http://${PROMETHEUS_IP}/api/v1/query  ${params}
    Status Should Be    OK
    Log  Received response from Prometheus ${resp.text}
    [return]  ${resp.json()}

ValidateResponseTime
    [Arguments]  ${job}  ${uri}  ${method}  ${timeLimit}
    [Documentation]  Check if uri response is under the required time
    ${resp}=  QueryPrometheus  http_server_requests_seconds_sum{uri="${uri}",method="${method}",job="${job}"}/http_server_requests_seconds_count{uri="${uri}",method="${method}",job="${job}"}
    ${rawNumber}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    ${actualTime}=   Set Variable  ${rawNumber * ${1000}}
    Should Be True   ${actualTime} <= ${timeLimit}

GetTopic
    [Arguments]    ${topic}
    Create Session   session  http://${DMAAP_IP}   max_retries=1
    ${params}=  Create Dictionary    limit    1    timeout    0
    ${resp}=    GET On Session    session    /events/${topic}/script/1    ${params}
    Status Should Be    OK    ${resp}

CheckTopic
    [Arguments]    ${topic}    ${expected_status}
    Create Session   session  http://${DMAAP_IP}   max_retries=1
    ${params}=  Create Dictionary    limit    1
    ${resp}=    GET On Session    session    /events/${topic}/script/1    ${params}
    Log  Received response from dmaap ${resp.text}
    Status Should Be    OK    ${resp}
    Should Contain    ${resp.text}    ${expected_status}
    [Return]    ${resp.text}
