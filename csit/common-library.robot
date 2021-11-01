*** Settings ***
Library    Collections
Library    RequestsLibrary
Library    OperatingSystem
Library    json

*** Keywords ***

PerformPostRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${postjson}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  POST On Session  policy  ${url}  data=${postjson}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformPutRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  PUT On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformGetRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}  ${params}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  GET On Session  policy  ${url}  params=${params}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
    [return]  ${resp}

PerformDeleteRequest
    [Arguments]  ${hostname}  ${url}  ${expectedstatus}
    ${auth}=  Create List  healthcheck  zb!XztG34
    Log  Creating session https://${hostname}:6969
    ${session}=  Create Session  policy  https://${hostname}:6969  auth=${auth}
    ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
    ${resp}=  DELETE On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
    Log  Received response from policy ${resp.text}
