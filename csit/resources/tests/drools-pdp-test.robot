*** Settings ***
Library  Collections
Library  RequestsLibrary
Library  OperatingSystem
Library  json

*** Test Cases ***
Alive
   [Documentation]  Runs Policy PDP Alive Check
   ${auth}=  Create List  demo@people.osaaf.org  demo123456!
   Log  Creating session http://${POLICY_DROOLS_IP}
   ${session}=  Create Session  policy  http://${POLICY_DROOLS_IP}  auth=${auth}
   ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
   ${resp}=  GET On Session  policy  /policy/pdp/engine  headers=${headers}  expected_status=200
   Log  Received response from policy ${resp.text}
   Should Be Equal As Strings  ${resp.json()['alive']}  True

Metrics
   [Documentation]  Verify drools-pdp is exporting metrics
   ${auth}=  Create List  demo@people.osaaf.org  demo123456!
   Log  Creating session http://${POLICY_DROOLS_IP}
   ${session}=  Create Session  policy  http://${POLICY_DROOLS_IP}  auth=${auth}
   ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
   ${resp}=  GET On Session  policy  /metrics  headers=${headers}  expected_status=200
   Log  Received response from policy ${resp.text}
   Should Contain  ${resp.text}  jvm_threads_current
