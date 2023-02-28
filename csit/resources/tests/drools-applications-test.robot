*** Settings ***
Library     Collections
Library     String
Library     RequestsLibrary
Library     OperatingSystem
Library     Process
Library     json
Resource    common-library.robot

*** Test Cases ***
Alive
    [Documentation]    Runs Policy PDP Alive Check
    ${resp}=  PeformGetRequest  /policy/pdp/engine  ${DROOLS_IP_2}  200
    Should Be Equal As Strings    ${resp.json()['alive']}  True

Metrics
    [Documentation]    Verify drools-apps is exporting metrics
    ${resp}=  PeformGetRequest  /metrics  ${DROOLS_IP_2}  200
    Should Contain  ${resp.text}  jvm_threads_current

Healthcheck
    [Documentation]    Runs Policy PDP-D Health check
    ${resp}=  PeformGetRequest  /healthcheck  ${DROOLS_IP}  200
    Should Be Equal As Strings    ${resp.json()['healthy']}  True

Controller
    [Documentation]    Checks controller is up
    Wait Until Keyword Succeeds  2 min  15 sec  VerifyController

MakeTopics
    [Documentation]    Creates the Policy topics
    GetTopic     POLICY-PDP-PAP
    GetTopic     POLICY-CL-MGT

CreateVcpeXacmlPolicy
    [Documentation]    Create VCPE Policy for Xacml
    PerformPostRequest  /policy/api/v1/policies  null  ${POLICY_API_IP}  vCPE.policy.monitoring.input.tosca.yaml  ${DATA}  yaml  200

CreateVcpeDroolsPolicy
    [Documentation]    Create VCPE Policy for Drools
    PerformPostRequest  /policy/api/v1/policies  null  ${POLICY_API_IP}  vCPE.policy.operational.input.tosca.yaml  ${DATA}  yaml  200

CreateVdnsXacmlPolicy
    [Documentation]    Create VDNS Policy for Xacml
    PerformPostRequest  /policy/api/v1/policies  null  ${POLICY_API_IP}  vDNS.policy.monitoring.input.tosca.yaml  ${DATA}  yaml  200

CreateVdnsDroolsPolicy
    [Documentation]    Create VDNS Policy for Drools
    PerformPostRequest  /policy/api/v1/policies  null  ${POLICY_API_IP}  vDNS.policy.operational.input.tosca.json  ${DATA}  json  200

CreateVfwXacmlPolicy
    [Documentation]    Create VFW Policy for Xacml
    PerformPostRequest  /policy/api/v1/policies  null  ${POLICY_API_IP}  vFirewall.policy.monitoring.input.tosca.yaml  ${DATA}  yaml  200

CreateVfwDroolsPolicy
    [Documentation]    Create VFW Policy for Drools
    PerformPostRequest  /policy/api/v1/policies  null  ${POLICY_API_IP}  vFirewall.policy.operational.input.tosca.json  ${DATA}  json  200

DeployXacmlPolicies
    [Documentation]    Deploys the Policies to Xacml
    PerformPostRequest  /policy/pap/v1/pdps/deployments/batch  null  ${POLICY_PAP_IP}  deploy.xacml.policies.json  ${CURDIR}/data  json  202
    ${result}=    CheckTopic     POLICY-PDP-PAP    PDP_UPDATE
    Sleep    5s
    ${result}=    CheckTopic     POLICY-PDP-PAP    ACTIVE
    Should Contain    ${result}    responseTo
    Should Contain    ${result}    xacml
    Should Contain    ${result}    restart
    Should Contain    ${result}    onap.restart.tca
    Should Contain    ${result}    onap.scaleout.tca
    Should Contain    ${result}    onap.vfirewall.tca

DeployDroolsPolicies
    [Documentation]    Deploys the Policies to Drools
    PerformPostRequest  /policy/pap/v1/pdps/deployments/batch  null  ${POLICY_PAP_IP}  deploy.drools.policies.json  ${CURDIR}/data  json  202
    ${result}=    CheckTopic     POLICY-PDP-PAP    PDP_UPDATE
    Sleep    5s
    ${result}=    CheckTopic     POLICY-PDP-PAP    ACTIVE
    Should Contain    ${result}    responseTo
    Should Contain    ${result}    drools
    Should Contain    ${result}    operational.restart
    Should Contain    ${result}    operational.scaleout
    Should Contain    ${result}    operational.modifyconfig

VcpeExecute
    [Documentation]    Executes VCPE Policy
    OnSet     ${CURDIR}/data/vcpeOnset.json
    ${result}=    CheckTopic     POLICY-CL-MGT    ACTIVE
    Should Contain    ${result}    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Should Contain    ${result}    Sending guard query for APPC Restart
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Should Contain    ${result}    Guard result for APPC Restart is Permit
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Should Contain    ${result}    actor=APPC,operation=Restart
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION: SUCCESS
    Should Contain    ${result}    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Should Contain    ${result}    actor=APPC,operation=Restart
    ${result}=    CheckTopic     POLICY-CL-MGT    FINAL: SUCCESS
    Should Contain    ${result}    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    Should Contain    ${result}    APPC
    Should Contain    ${result}    Restart

VdnsExecute
    [Documentation]    Executes VDNS Policy
    OnSet     ${CURDIR}/data/vdnsOnset.json
    ${result}=    CheckTopic     POLICY-CL-MGT    ACTIVE
    Should Contain    ${result}    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Should Contain    ${result}    Sending guard query for SO VF Module Create
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Should Contain    ${result}    Guard result for SO VF Module Create is Permit
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Should Contain    ${result}    actor=SO,operation=VF Module Create
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION: SUCCESS
    Should Contain    ${result}    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Should Contain    ${result}    actor=SO,operation=VF Module Create
    ${result}=    CheckTopic     POLICY-CL-MGT    FINAL: SUCCESS
    Should Contain    ${result}    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    Should Contain    ${result}    SO
    Should Contain    ${result}    VF Module Create

VfwExecute
    [Documentation]    Executes VFW Policy
    OnSet     ${CURDIR}/data/vfwOnset.json
    ${result}=    CheckTopic     POLICY-CL-MGT    ACTIVE
    Should Contain    ${result}    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Should Contain    ${result}    Sending guard query for APPC ModifyConfig
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Should Contain    ${result}    Guard result for APPC ModifyConfig is Permit
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION
    Should Contain    ${result}    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Should Contain    ${result}    actor=APPC,operation=ModifyConfig
    ${result}=    CheckTopic     POLICY-CL-MGT    OPERATION: SUCCESS
    Should Contain    ${result}    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Should Contain    ${result}    actor=APPC,operation=ModifyConfig
    ${result}=    CheckTopic     POLICY-CL-MGT    FINAL: SUCCESS
    Should Contain    ${result}    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    Should Contain    ${result}    APPC
    Should Contain    ${result}    ModifyConfig

*** Keywords ***

VerifyController
    ${resp}=  PeformGetRequest  /policy/pdp/engine/controllers/usecases/drools/facts  ${DROOLS_IP_2}  200
    Should Be Equal As Strings  ${resp.json()['usecases']}  1

PeformGetRequest
     [Arguments]  ${url}  ${domain}  ${expectedstatus}
     ${auth}=  Create List  demo@people.osaaf.org  demo123456!
     Log  Creating session http://${domain}
     ${session}=  Create Session  policy  http://${domain}  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/json  Content-Type=application/json
     ${resp}=  GET On Session  policy  ${url}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}

PerformPostRequest
     [Arguments]  ${url}  ${params}  ${domain}  ${jsonfile}  ${filepath}  ${contenttype}  ${expectedstatus}
     ${auth}=  Create List  policyadmin  zb!XztG34
     ${postjson}=  Get file  ${filepath}/${jsonfile}
     Log  Creating session http://${domain}
     ${session}=  Create Session  policy  http://${domain}  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/${contenttype}  Content-Type=application/${contenttype}
     ${resp}=  POST On Session  policy  ${url}  params=${params}  data=${postjson}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     [return]  ${resp}

OnSet
    [Arguments]    ${file}
    ${data}=    Get File    ${file}
    Create Session   session  http://${DMAAP_IP}   max_retries=1
    ${headers}=  Create Dictionary  Content-Type=application/json
    ${resp}=  POST On Session    session    /events/unauthenticated.DCAE_CL_OUTPUT    headers=${headers}    data=${data}
    Log    Response from dmaap ${resp.text}
    Status Should Be    OK
    [Return]    ${resp.text}
