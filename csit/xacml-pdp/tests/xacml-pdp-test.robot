*** Settings ***
Library     Collections
Library     RequestsLibrary
Library     OperatingSystem
Library     Process
Library     json
Resource    ${CURDIR}/../../common-library.robot
Resource    ${CURDIR}/../../api-pap-common.robot

*** Test Cases ***
Healthcheck
     [Documentation]  Verify policy xacml-pdp health check
     ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/healthcheck  200  null
     Should Be Equal As Strings    ${resp.json()['code']}  200

Statistics
     [Documentation]  Verify policy xacml-pdp statistics
     ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/statistics  200  null
     Should Be Equal As Strings    ${resp.json()['code']}  200

Metrics
    [Documentation]  Verify policy-xacml-pdp is exporting prometheus metrics
    ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  /metrics  200  null
    Should Contain  ${resp.text}  jvm_threads_current

MakeTopics
     [Documentation]    Creates the Policy topics
     ${result}=     Run Process     ${SCR_DMAAP}/make_topic.sh   POLICY-PDP-PAP
     Should Be Equal As Integers        ${result.rc}    0

ExecuteXacmlPolicy
     CreateMonitorPolicy
     CreateOptimizationPolicy
     Wait Until Keyword Succeeds    1 min   15 sec  GetDefaultDecision
     DeployPolicies
     Wait Until Keyword Succeeds    1 min   15 sec  GetStatisticsAfterDeployed
     Wait Until Keyword Succeeds    1 min   15 sec  GetAbbreviatedDecisionResult
     Wait Until Keyword Succeeds    1 min   15 sec  GetMonitoringDecision
     Wait Until Keyword Succeeds    1 min   15 sec  GetNamingDecision
     Wait Until Keyword Succeeds    1 min   15 sec  GetOptimizationDecision
     Wait Until Keyword Succeeds    1 min   15 sec  GetStatisticsAfterDecision
     UndeployMonitorPolicy
     Wait Until Keyword Succeeds    1 min   15 sec  GetStatisticsAfterUndeploy

*** Keywords ***

CreateMonitorPolicy
     [Documentation]  Create a Monitoring policy
     ${postjson}=  Get file  ${DATA2}/vCPE.policy.monitoring.input.tosca.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.monitoring.tcagen2/versions/1.0.0/policies  200  ${postjson}  onap.restart.tca  1.0.0

CreateOptimizationPolicy
     [Documentation]  Create an Optimization policy
     ${postjson}=  Get file  ${DATA2}/vCPE.policies.optimization.input.tosca.json
     CreatePolicy  /policy/api/v1/policytypes/onap.policies.optimization.resource.AffinityPolicy/versions/1.0.0/policies  200  ${postjson}  OSDF_CASABLANCA.Affinity_Default  1.0.0

GetDefaultDecision
     [Documentation]  Get Default Decision with no policies in Xacml PDP
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.guard.decision.request.json
     ${resp}=  PerformPostRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/decision  200  ${postjson}  abbrev=true
     ${status}=  Get From Dictionary  ${resp.json()}  status
     Should Be Equal As Strings  ${status}  Permit

DeployPolicies
     [Documentation]   Runs Policy PAP to deploy a policy
     ${postjson}=  Get file  ${CURDIR}/data/vCPE.policy.input.tosca.deploy.json
     PapApiPostRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/policies  202  ${postjson}  null
     ${result}=     Run Process    ${SCR_DMAAP}/wait_topic.sh    POLICY-PDP-PAP
     ...            responseTo    xacml    ACTIVE    onap.restart.tca
     Should Be Equal As Integers        ${result.rc}    0

GetStatisticsAfterDeployed
     [Documentation]  Verify policy xacml-pdp statistics after policy is deployed
     ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/statistics  200  null
     Should Be Equal As Strings  ${resp.json()['code']}  200
     Should Be Equal As Strings  ${resp.json()['totalPoliciesCount']}  3

GetAbbreviatedDecisionResult
     [Documentation]    Get Decision with abbreviated results from Policy Xacml PDP
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.monitoring.decision.request.json
     ${resp}=  PerformPostRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/decision  200  ${postjson}  abbrev=true
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
     ${resp}=  PerformPostRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/decision  200  ${postjson}  null
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
     ${resp}=  PerformPostRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/decision  200  ${postjson}  null
     ${policy}=    Get From Dictionary    ${resp.json()['policies']}   SDNC_Policy.ONAP_NF_NAMING_TIMESTAMP
     Dictionary Should Contain Key    ${policy}    type
     Dictionary Should Contain Key    ${policy}    type_version
     Dictionary Should Contain Key    ${policy}    properties
     Dictionary Should Contain Key    ${policy}    name

GetOptimizationDecision
     [Documentation]    Get Decision from Optimization Policy Xacml PDP
     ${postjson}=  Get file  ${CURDIR}/data/onap.policy.optimization.decision.request.json
     ${resp}=  PerformPostRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/decision  200  ${postjson}  null
     ${policy}=    Get From Dictionary    ${resp.json()['policies']}   OSDF_CASABLANCA.Affinity_Default
     Dictionary Should Contain Key    ${policy}    type
     Dictionary Should Contain Key    ${policy}    type_version
     Dictionary Should Contain Key    ${policy}    properties
     Dictionary Should Contain Key    ${policy}    name

GetStatisticsAfterDecision
     [Documentation]    Runs Policy Xacml PDP Statistics after Decision request
     ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/statistics  200  null
     Should Be Equal As Strings    ${resp.json()['code']}  200
     Should Be Equal As Strings    ${resp.json()['permitDecisionsCount']}     4
     Should Be Equal As Strings    ${resp.json()['notApplicableDecisionsCount']}     1

UndeployMonitorPolicy
     [Documentation]    Runs Policy PAP to undeploy a policy
     PapApiDeleteRequest  ${POLICY_PAP_IP}  /policy/pap/v1/pdps/policies/onap.restart.tca  202

GetStatisticsAfterUndeploy
     [Documentation]    Runs Policy Xacml PDP Statistics after policy is undeployed
     ${resp}=  PerformGetRequest  ${POLICY_PDPX_IP}  /policy/pdpx/v1/statistics  200  null
     Should Be Equal As Strings    ${resp.json()['code']}  200
     Should Be Equal As Strings    ${resp.json()['totalPoliciesCount']}     2
