*** Settings ***
Library    Collections
Library    String
Library    RequestsLibrary
Library    OperatingSystem
Library    Process
Library    json
Resource    common-library.robot

*** Test Cases ***
Alive
    [Documentation]    Runs Policy PDP Alive Check
    ${resp}=  PerformGetRequestOnDrools  /policy/pdp/engine  ${DROOLS_IP_2}  200
    Should Be Equal As Strings    ${resp.json()['alive']}  True

Metrics
    [Documentation]    Verify drools-apps is exporting metrics
    ${resp}=  PerformGetRequestOnDrools  /metrics  ${DROOLS_IP_2}  200
    Should Contain  ${resp.text}  jvm_threads_current

Healthcheck
    [Documentation]    Runs Policy PDP-D Health check
    ${resp}=  PerformGetRequestOnDrools  /healthcheck  ${DROOLS_IP}  200
    Should Be Equal As Strings    ${resp.json()['healthy']}  True

Controller
    [Documentation]    Checks controller is up
    Wait Until Keyword Succeeds  2 min  15 sec  VerifyController

AssertTopicsOnKafkaClient
    [Documentation]    Verify that the Policy topics policy-pdp-pap and policy-cl-mgt are available on kafka
    GetKafkaTopic    policy-pdp-pap
    GetKafkaTopic    policy-cl-mgt

CheckTopics
    [Documentation]    List the topics registered with TopicManager
    ${resp}=  PerformGetRequestOnDrools  /policy/pdp/engine/topics  ${DROOLS_IP_2}  200
    Should Contain    ${resp.text}    policy-cl-mgt
    Should Contain    ${resp.text}    policy-pdp-pap
    Should Contain    ${resp.text}    dcae_topic

CheckEngineFeatures
    [Documentation]    List the features available in the drools engine
    ${resp}=  PerformGetRequestOnDrools  /policy/pdp/engine/features  ${DROOLS_IP_2}  200
    Should Contain    ${resp.text}    "org.onap.policy.drools.lifecycle.LifecycleFeature"
    Should Contain    ${resp.text}    "org.onap.policy.drools.apps.controlloop.feature.usecases.UsecasesFeature"
    Should Contain    ${resp.text}    "org.onap.policy.drools.healthcheck.HealthCheckFeature"

CheckPolicyTypes
    [Documentation]    Check if the needed Policy types are available
    ${auth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest    ${POLICY_API_IP}    /policy/api/v1/policytypes    200  null  ${auth}
    Should Contain    ${resp.text}    onap.policies.monitoring.tcagen2
    Should Contain    ${resp.text}    onap.policies.controlloop.operational.common.Drools

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

CheckCreatedPolicies
    [Documentation]    Verify that all created policies are available for deployment
    ${auth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest    ${POLICY_API_IP}    /policy/api/v1/policies    200  null  ${auth}
    #vcpe xacml
    Should Contain    ${resp.text}    onap.restart.tca
    #vcpe drools
    Should Contain    ${resp.text}    operational.restart
    #vnds xacml
    Should Contain    ${resp.text}    onap.scaleout.tca
    #vnds drools
    Should Contain    ${resp.text}    operational.scaleout
    #vfirewall xacml
    Should Contain    ${resp.text}    onap.vfirewall.tca
    #vfirewall drools
    Should Contain    ${resp.text}    operational.modifyconfig

DeployXacmlPolicies
    [Documentation]    Deploys the Policies to Xacml
    DeployPolicy  deploy.xacml.policies.json
    Sleep  5s
    @{otherMessages}=   Create List    deployed-policies   onap.scaleout.tca    onap.restart.tca
    AssertMessageFromTopic    policy-notification    onap.vfirewall.tca    ${otherMessages}

VerifyDeployedXacmlPolicies
    [Documentation]    Verify if xacml policies were deployed correctly
    ${resp}=    GetDeployedPolicies
    @{policies}=   Create List    onap.vfirewall.tca    onap.scaleout.tca    onap.restart.tca
    FOR    ${policy}    IN    @{policies}
       Should Contain    ${resp.text}    ${policy}
    END

DeployDroolsPolicies
    [Documentation]    Deploys the Policies to Drools
    DeployPolicy   deploy.drools.policies.json
    Sleep  5s
    @{otherMessages}=   Create List    deployed-policies   operational.scaleout    operational.restart
    AssertMessageFromTopic    policy-notification    operational.modifyconfig    ${otherMessages}

VerifyDeployedDroolsPolicies
    [Documentation]    Verify if drools policies were deployed correctly
    ${resp}=    GetDeployedPolicies
    @{policies}=   Create List    operational.modifyconfig    operational.scaleout    operational.restart
    FOR    ${policy}    IN    @{policies}
       Should Contain    ${resp.text}    ${policy}
    END

VcpeExecute
    [Documentation]    Executes VCPE Policy
    OnSet    ${CURDIR}/data/drools/vcpeOnset.json
    ${policyExecuted}=  Set Variable    ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e
    @{otherMessages}=   Create List    ACTIVE
    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    ${policyExecuted}    OPERATION
    AssertMessageFromTopic    policy-cl-mgt   Sending guard query for APPC Restart   ${otherMessages}

    AssertMessageFromTopic    policy-cl-mgt   Guard result for APPC Restart is Permit   ${otherMessages}

    AssertMessageFromTopic    policy-cl-mgt   actor=APPC,operation=Restart   ${otherMessages}

#    @{otherMessages}=   Create List    OPERATION: SUCCESS   actor=APPC,operation=Restart
#    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    FINAL: SUCCESS   APPC    Restart
#    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}

VdnsExecute
    [Documentation]    Executes VDNS Policy
    OnSet    ${CURDIR}/data/drools/vdnsOnset.json
    ${policyExecuted}=  Set Variable    ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3
    @{otherMessages}=   Create List    ACTIVE
    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    ${policyExecuted}    OPERATION
    AssertMessageFromTopic    policy-cl-mgt   Sending guard query for SO VF Module Create   ${otherMessages}

    AssertMessageFromTopic    policy-cl-mgt   Guard result for SO VF Module Create is Permit   ${otherMessages}

    AssertMessageFromTopic    policy-cl-mgt   actor=SO,operation=VF Module Create   ${otherMessages}

    @{otherMessages}=   Create List    ${policyExecuted}    OPERATION: SUCCESS
    AssertMessageFromTopic    policy-cl-mgt   actor=SO,operation=VF Module Create   ${otherMessages}

    @{otherMessages}=   Create List    ${policyExecuted}    FINAL: SUCCESS   SO
    AssertMessageFromTopic    policy-cl-mgt   VF Module Create   ${otherMessages}

VfwExecute
    [Documentation]    Executes VFW Policy
    OnSet    ${CURDIR}/data/drools/vfwOnset.json
    ${policyExecuted}=  Set Variable    ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a
    @{otherMessages}=   Create List    ACTIVE
    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}

    @{otherMessages}=   Create List    ${policyExecuted}    OPERATION
    AssertMessageFromTopic    policy-cl-mgt   Sending guard query for APPC ModifyConfig   ${otherMessages}

    AssertMessageFromTopic    policy-cl-mgt   Guard result for APPC ModifyConfig is Permit   ${otherMessages}

    AssertMessageFromTopic    policy-cl-mgt   actor=APPC,operation=ModifyConfig   ${otherMessages}

#    @{otherMessages}=   Create List    OPERATION: SUCCESS    actor=APPC,operation=ModifyConfig
#    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}
#
#    @{otherMessages}=   Create List    FINAL: SUCCESS    APPC   ModifyConfig
#    AssertMessageFromTopic    policy-cl-mgt   ${policyExecuted}   ${otherMessages}


*** Keywords ***

VerifyController
    ${resp}=  PerformGetRequestOnDrools  /policy/pdp/engine/controllers/usecases/drools/facts  ${DROOLS_IP_2}  200
    Should Be Equal As Strings  ${resp.json()['usecases']}  1

PerformGetRequestOnDrools
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
    ${resp}=    Run Process    ${CURDIR}/kafka_producer.py    dcae_topic    ${data}    ${KAFKA_IP}
    Log    Response from kafka ${resp.stdout}
    RETURN    ${resp.stdout}

CreatePolicy
    [Arguments]    ${policyFile}   ${contenttype}
    PerformPostRequest  /policy/api/v1/policies  ${POLICY_API_IP}  ${policyFile}  ${DATA}  ${contenttype}  201

DeployPolicy
    [Arguments]    ${policyName}
    PerformPostRequest  /policy/pap/v1/pdps/deployments/batch  ${POLICY_PAP_IP}  ${policyName}  ${CURDIR}/data/drools  json  202

AssertMessageFromTopic
    [Arguments]    ${topic}    ${topicMessage}    ${otherMessages}
    ${response}=    Wait Until Keyword Succeeds    4 x    10 sec    CheckKafkaTopic    ${topic}    ${topicMessage}
    FOR    ${msg}    IN    @{otherMessages}
       Should Contain    ${response}    ${msg}
    END

GetDeployedPolicies
    ${auth}=  PolicyAdminAuth
    ${resp}=    PerformGetRequest    ${POLICY_PAP_IP}    /policy/pap/v1/policies/deployed    200  null  ${auth}
    RETURN    ${resp}

VerifyEventsOnTopic
    [Arguments]    ${topic}    ${type}
    ${resp}=    PerformGetRequestOnDrools    /policy/pdp/engine/topics/${type}/kafka/${topic}/events    ${DROOLS_IP_2}  200
    Log    Events: ${resp.json()}
    RETURN    ${resp}
