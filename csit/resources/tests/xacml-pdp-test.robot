*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     Process
Library     json
Resource    common-library.robot

*** Test Cases ***
Healthcheck
    [Documentation]  Verify policy xacml-pdp health check
    ${resp}=  PdpxGetReq  /policy/pdpx/v1/healthcheck
    Should Be Equal As Strings    ${resp.json()['code']}  200

Metrics
    [Documentation]  Verify policy-xacml-pdp is exporting prometheus metrics
    ${resp}=  PdpxGetReq  /metrics
    Should Contain  ${resp.text}  jvm_threads_current

MakeTopics
    [Documentation]    Creates the Policy topics
    GetKafkaTopic   policy-pdp-pap

ExecuteXacmlPolicy
    CreateMonitorPolicy
    CreateOptimizationPolicy
    Wait Until Keyword Succeeds    1 min   15 sec  GetDefaultDecision
    DeployPolicies
    Wait Until Keyword Succeeds    1 min   15 sec  GetAbbreviatedDecisionResult
    Wait Until Keyword Succeeds    1 min   15 sec  GetMonitoringDecision
    Wait Until Keyword Succeeds    1 min   15 sec  GetNamingDecision
    Wait Until Keyword Succeeds    1 min   15 sec  GetOptimizationDecision
    UndeployMonitorPolicy

*** Keywords ***

CreateMonitorPolicy
    [Documentation]  Create a Monitoring policy
    ${postjson}=  Get file  ${DATA}/vCPE.policy.monitoring.input.tosca.json
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  201  ${postjson}  onap.restart.tca  1.0.0

CreateOptimizationPolicy
    [Documentation]  Create an Optimization policy
    ${postjson}=  Get file  ${DATA}/vCPE.policies.optimization.input.tosca.json
    CreatePolicy  /policy/api/v1/policytypes/onap.policies.optimization.resource.AffinityPolicy/versions/1.0.0/policies  201  ${postjson}  OSDF_CASABLANCA.Affinity_Default  1.0.0

GetDefaultDecision
    [Documentation]  Get Default Decision with no policies in Xacml PDP
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.guard.decision.request.json
    ${resp}=  DecisionPostReq  ${postjson}  abbrev=true
    ${status}=  Get From Dictionary  ${resp.json()}  status
    Should Be Equal As Strings  ${status}  Permit

DeployPolicies
    [Documentation]   Runs Policy PAP to deploy a policy
    ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.input.tosca.deploy.json
    ${policyadmin}=  PolicyAdminAuth
    PerformPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/policies  202  ${postjson}  null  ${policyadmin}
    sleep  20s
    ${result}=     CheckKafkaTopic    policy-notification     onap.restart.tca
    Should Contain    ${result}    deployed-policies

GetAbbreviatedDecisionResult
    [Documentation]    Get Decision with abbreviated results from Policy Xacml PDP
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.decision.request.json
    ${resp}=  DecisionPostReq  ${postjson}  abbrev=true
    ${policy}=    Get From Dictionary    ${resp.json()['policies']}   onap.restart.tca
    Dictionary Should Contain Key    ${policy}    type
    Dictionary Should Contain Key    ${policy}    metadata
    Dictionary Should Not Contain Key    ${policy}    type_version
    Dictionary Should Not Contain Key    ${policy}    properties
    Dictionary Should Not Contain Key    ${policy}    name
    Dictionary Should Not Contain Key    ${policy}    version

GetMonitoringDecision
    [Documentation]    Get Decision from Monitoring Policy Xacml PDP
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.decision.request.json
    ${resp}=  DecisionPostReq  ${postjson}  null
    ${policy}=    Get From Dictionary    ${resp.json()['policies']}   onap.restart.tca
    Dictionary Should Contain Key    ${policy}    type
    Dictionary Should Contain Key    ${policy}    metadata
    Dictionary Should Contain Key    ${policy}    type_version
    Dictionary Should Contain Key    ${policy}    properties
    Dictionary Should Contain Key    ${policy}    name
    Dictionary Should Contain Key    ${policy}    version

GetNamingDecision
    [Documentation]    Get Decision from Naming Policy Xacml PDP
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.naming.decision.request.json
    ${resp}=  DecisionPostReq  ${postjson}  null
    ${policy}=    Get From Dictionary    ${resp.json()['policies']}   SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP
    Dictionary Should Contain Key    ${policy}    type
    Dictionary Should Contain Key    ${policy}    type_version
    Dictionary Should Contain Key    ${policy}    properties
    Dictionary Should Contain Key    ${policy}    name

GetOptimizationDecision
    [Documentation]    Get Decision from Optimization Policy Xacml PDP
    ${postjson}=  Get file  ${CURDIR}/data/onap.policy.optimization.decision.request.json
    ${resp}=  DecisionPostReq  ${postjson}  null
    ${policy}=    Get From Dictionary    ${resp.json()['policies']}   OSDF_CASABLANCA.Affinity_Default
    Dictionary Should Contain Key    ${policy}    type
    Dictionary Should Contain Key    ${policy}    type_version
    Dictionary Should Contain Key    ${policy}    properties
    Dictionary Should Contain Key    ${policy}    name

UndeployMonitorPolicy
    [Documentation]    Runs Policy PAP to undeploy a policy
    ${policyadmin}=  PolicyAdminAuth
    PerformDeleteRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/policies/onap.restart.tca  202  ${policyadmin}

PdpxGetReq
    [Arguments]  ${url}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  ${url}  200  null  ${hcauth}
    RETURN  ${resp}

DecisionPostReq
    [Arguments]  ${postjson}  ${abbr}
    ${hcauth}=  PolicyAdminAuth
    ${resp}=  PerformPostRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/decision  200  ${postjson}  ${abbr}  ${hcauth}
    RETURN  ${resp}
