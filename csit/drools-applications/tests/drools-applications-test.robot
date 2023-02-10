*** Settings ***
Library     Collections
Library     String
Library     RequestsLibrary
Library     OperatingSystem
Library     Process
Library     json

*** Test Cases ***
Alive
    [Documentation]    Runs Policy PDP Alive Check
    ${resp}=  PeformGetRequest  /policy/pdp/engine  30219  200
    Should Be Equal As Strings    ${resp.json()['alive']}  True

Metrics
    [Documentation]    Verify drools-apps is exporting metrics
    ${resp}=  PeformGetRequest  /metrics  30219  200
    Should Contain  ${resp.text}  jvm_threads_current

Healthcheck
    [Documentation]    Runs Policy PDP-D Health check
    ${resp}=  PeformGetRequest  /healthcheck  ${DROOLS_PORT}  200
    Should Be Equal As Strings    ${resp.json()['healthy']}  True

Controller
    [Documentation]    Checks controller is up
    Wait Until Keyword Succeeds  2 min  15 sec  VerifyController

MakeTopics
    [Documentation]    Creates the Policy topics
    ${result}=     Run Process        ${SCR2}/make_topic.sh     POLICY-PDP-PAP
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/make_topic.sh     POLICY-CL-MGT
    Should Be Equal As Integers        ${result.rc}    0

CreateVcpeXacmlPolicy
    [Documentation]    Create VCPE Policy for Xacml
    PerformPostRequest  /policy/api/v1/policies  null  ${API_PORT}  vCPE.policy.monitoring.input.tosca.yaml  ${DATA}  yaml  200

CreateVcpeDroolsPolicy
    [Documentation]    Create VCPE Policy for Drools
    PerformPostRequest  /policy/api/v1/policies  null  ${API_PORT}  vCPE.policy.operational.input.tosca.yaml  ${DATA}  yaml  200

CreateVdnsXacmlPolicy
    [Documentation]    Create VDNS Policy for Xacml
    PerformPostRequest  /policy/api/v1/policies  null  ${API_PORT}  vDNS.policy.monitoring.input.tosca.yaml  ${DATA}  yaml  200

CreateVdnsDroolsPolicy
    [Documentation]    Create VDNS Policy for Drools
    PerformPostRequest  /policy/api/v1/policies  null  ${API_PORT}  vDNS.policy.operational.input.tosca.json  ${DATA}  json  200

CreateVfwXacmlPolicy
    [Documentation]    Create VFW Policy for Xacml
    PerformPostRequest  /policy/api/v1/policies  null  ${API_PORT}  vFirewall.policy.monitoring.input.tosca.yaml  ${DATA}  yaml  200

CreateVfwDroolsPolicy
    [Documentation]    Create VFW Policy for Drools
    PerformPostRequest  /policy/api/v1/policies  null  ${API_PORT}  vFirewall.policy.operational.input.tosca.json  ${DATA}  json  200

DeployXacmlPolicies
    [Documentation]    Deploys the Policies to Xacml
    PerformPostRequest  /policy/pap/v1/pdps/deployments/batch  null  ${PAP_PORT}  deploy.xacml.policies.json  ${DATA2}  json  202
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-PDP-PAP
    ...            responseTo    xacml    ACTIVE    restart
    Log    Received status ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    onap.restart.tca
    Should Contain    ${result.stdout}    onap.scaleout.tca
    Should Contain    ${result.stdout}    onap.vfirewall.tca

DeployDroolsPolicies
    [Documentation]    Deploys the Policies to Drools
    PerformPostRequest  /policy/pap/v1/pdps/deployments/batch  null  ${PAP_PORT}  deploy.drools.policies.json  ${DATA2}  json  202
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-PDP-PAP
    ...            responseTo    drools    ACTIVE
    Log    Received status ${result.stdout}
    Sleep    3s
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    operational.restart
    Should Contain    ${result.stdout}    operational.scaleout
    Should Contain    ${result.stdout}    operational.modifyconfig

VcpeExecute
    [Documentation]    Executes VCPE Policy
    ${result}=     Run Process        ${SCR2}/onset.sh     ${DATA2}/vcpeOnset.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    ACTIVE
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Sending guard query for APPC Restart
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Guard result for APPC Restart is Permit
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    actor=APPC,operation=Restart
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION: SUCCESS
    Should Contain    ${result.stdout}    actor=APPC,operation=Restart
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    FINAL: SUCCESS
    Should Contain    ${result.stdout}    APPC
    Should Contain    ${result.stdout}    Restart

VdnsExecute
    [Documentation]    Executes VDNS Policy
    ${result}=     Run Process        ${SCR2}/onset.sh     ${DATA2}/vdnsOnset.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    ACTIVE
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Sending guard query for SO VF Module Create
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Guard result for SO VF Module Create is Permit
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    actor=SO,operation=VF Module Create
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION: SUCCESS
    Should Contain    ${result.stdout}    actor=SO,operation=VF Module Create
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    FINAL: SUCCESS
    Should Contain    ${result.stdout}    SO
    Should Contain    ${result.stdout}    VF Module Create

VfwExecute
    [Documentation]    Executes VFW Policy
    ${result}=     Run Process        ${SCR2}/onset.sh     ${DATA2}/vfwOnset.json
    Should Be Equal As Integers        ${result.rc}    0
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    ACTIVE
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Sending guard query for APPC ModifyConfig
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    Guard result for APPC ModifyConfig is Permit
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION
    Should Contain    ${result.stdout}    actor=APPC,operation=ModifyConfig
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    OPERATION: SUCCESS
    Should Contain    ${result.stdout}    actor=APPC,operation=ModifyConfig
    ${result}=     Run Process        ${SCR2}/wait_topic.sh     POLICY-CL-MGT
    ...            ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Log    Received notification ${result.stdout}
    Should Be Equal As Integers        ${result.rc}    0
    Should Contain    ${result.stdout}    FINAL: SUCCESS
    Should Contain    ${result.stdout}    APPC
    Should Contain    ${result.stdout}    ModifyConfig

*** Keywords ***

VerifyController
    ${resp}=  PeformGetRequest  /policy/pdp/engine/controllers/usecases/drools/facts  30219  200
    Should Be Equal As Strings  ${resp.json()['usecases']}  1

PeformGetRequest
     [Arguments]  ${url}  ${port}  ${expectedstatus}
     ${auth}=  Create List  demo@people.osaaf.org  demo123456!
     Log  Creating session http://localhost:${port}
     ${session}=  Create Session  policy  http://localhost:${port}  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
     ${resp}=  GET On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}

PerformPostRequest
     [Arguments]  ${url}  ${params}  ${port}  ${jsonfile}  ${filepath}  ${contenttype}  ${expectedstatus}
     ${auth}=  Create List  policyadmin  zb!XztG34
     ${postjson}=  Get file  ${filepath}/${jsonfile}
     Log  Creating session http://localhost:${port}
     ${session}=  Create Session  policy  http://localhost:${port}  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/${contenttype}  Content-Type=application/${contenttype}
     ${resp}=  POST On Session  policy  ${url}  params=${params}  data=${postjson}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}
