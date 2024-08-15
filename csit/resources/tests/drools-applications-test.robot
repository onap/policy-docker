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
    GetKafkaTopic     policy-pdp-pap
    GetKafkaTopic     policy-cl-mgt

CreateVcpeXacmlPolicy
    [Documentation]    Create VCPE Policy for Xacml
    CreatePolicy  vCPE.policy.monitoring.input.tosca.yaml  yaml

CreateVcpeDroolsPolicy
    [Documentation]    Create VCPE Policy for Drools
    CreatePolicy  vCPE.policy.operational.input.tosca.yaml  yaml

CreateVdnsXacmlPolicy
    [Documentation]    Create VDNS Policy for Xacml
    CreatePolicy    vDNS.policy.monitoring.input.tosca.yaml  yaml

CreateVdnsDroolsPolicy
    [Documentation]    Create VDNS Policy for Drools
    CreatePolicy  vDNS.policy.operational.input.tosca.json  json

CreateVfwXacmlPolicy
    [Documentation]    Create VFW Policy for Xacml
    CreatePolicy  vFirewall.policy.monitoring.input.tosca.yaml  yaml

CreateVfwDroolsPolicy
    [Documentation]    Create VFW Policy for Drools
    CreatePolicy  vFirewall.policy.operational.input.tosca.json  json

DeployXacmlPolicies
    [Documentation]    Deploys the Policies to Xacml
    DeployPolicy  deploy.xacml.policies.json
    Sleep  5s
    ${result}=    CheckKafkaTopic     policy-notification    onap.vfirewall.tca
    Should Contain    ${result}    deployed-policies
    Should Contain    ${result}    onap.scaleout.tca
    Should Contain    ${result}    onap.restart.tca

DeployDroolsPolicies
    [Documentation]    Deploys the Policies to Drools
    DeployPolicy   deploy.drools.policies.json
    Sleep  5s
    @{otherMessages}=   Create List     deployed-policies   operational.scaleout    operational.restart
    AssertMessageFromTopic    policy-notification    operational.modifyconfig    ${otherMessages}


#VcpeExecute
#    [Documentation]    Executes VCPE Policy
#    OnSet     ${CURDIR}/data/vcpeOnset.json
#    ${policyExecuted}=  Set Variable    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
#    @{otherMessages}=   Create List    ACTIVE
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION    Sending guard query for APPC Restart
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION    Guard result for APPC Restart is Permit
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION    actor=APPC,operation=Restart
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION: SUCCESS   actor=APPC,operation=Restart
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    FINAL: SUCCESS   APPC    Restart
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

VdnsExecute
    [Documentation]    Executes VDNS Policy
    OnSet     ${CURDIR}/data/vdnsOnset.json
    ${policyExecuted}=  Set Variable    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    @{otherMessages}=   Create List    ACTIVE
    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    OPERATION    Sending guard query for SO VF Module Create
    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    OPERATION    Guard result for SO VF Module Create is Permit
    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    OPERATION    actor=SO,operation=VF Module Create
    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    OPERATION: SUCCESS   actor=SO,operation=VF Module Create
    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    FINAL: SUCCESS   SO  VF Module Create
    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}

#VfwExecute
#    [Documentation]    Executes VFW Policy
#    OnSet     ${CURDIR}/data/vfwOnset.json
#    ${policyExecuted}=  Set Variable    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
#    @{otherMessages}=   Create List    ACTIVE
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION    Sending guard query for APPC ModifyConfig
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION    Guard result for APPC ModifyConfig is Permit
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION    actor=APPC,operation=ModifyConfig
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    OPERATION: SUCCESS    actor=APPC,operation=ModifyConfig
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    Log    "Checking if policy execution status is FINAL: SUCCESS"
#    @{otherMessages}=   Create List    FINAL: SUCCESS    APPC   ModifyConfig
#    AssertMessageFromTopic     policy-cl-mgt   ${policyExecuted}   ${otherMessages}


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
     RETURN  ${resp}

PerformPostRequest
     [Arguments]  ${url}  ${domain}  ${file}  ${folder}  ${contenttype}  ${expectedstatus}
     ${auth}=  Create List  policyadmin  zb!XztG34
     ${body}=  Get file  ${folder}/${file}
     Log  Creating session http://${domain}
     ${session}=  Create Session  policy  http://${domain}  auth=${auth}
     ${headers}=  Create Dictionary  Accept=application/${contenttype}  Content-Type=application/${contenttype}
     ${resp}=  POST On Session  policy  ${url}  data=${body}  headers=${headers}  expected_status=${expectedstatus}
     Log  Received response from policy ${resp.text}
     RETURN  ${resp}

OnSet
    [Arguments]    ${file}
    ${data}=    Get File    ${file}
    ${resp}=    Run Process    ${CURDIR}/kafka_producer.py    unauthenticated.dcae_cl_output    ${data}    ${KAFKA_IP}
    Log    Response from kafka ${resp.stdout}
    RETURN    ${resp.stdout}

CreatePolicy
    [Arguments]     ${policyFile}   ${contenttype}
    PerformPostRequest  /policy/api/v1/policies  ${POLICY_API_IP}  ${policyFile}  ${DATA}  ${contenttype}  201

DeployPolicy
    [Arguments]     ${policyName}
    PerformPostRequest  /policy/pap/v1/pdps/deployments/batch  ${POLICY_PAP_IP}  ${policyName}  ${CURDIR}/data  json  202

AssertMessageFromTopic
    [Arguments]     ${topic}    ${topicMessage}     ${otherMessages}
    ${response}=    Wait Until Keyword Succeeds    4 x    10 sec    CheckKafkaTopic    ${topic}    ${topicMessage}
    FOR    ${msg}    IN    @{otherMessages}
        Should Contain    ${response}    ${msg}
    END
