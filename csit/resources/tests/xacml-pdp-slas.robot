*** Settings ***
Library    OperatingSystem
Resource    common-library.robot

*** Test Cases ***
WaitForPrometheusServer
    [Documentation]  Sleep time to wait for Prometheus server to gather all metrics
    Sleep    1 minute

ValidatePolicyDecisionsTotalCounter
    [Documentation]    Validate policy decision counters using prometheus metrics
    ValidatePrometheusMetric   pdpx_policy_decisions_total{application="optimization",status="permit", instance="policy-xacml-pdp:6969", job="xacml-pdp-metrics"}  1
    ValidatePrometheusMetric   pdpx_policy_decisions_total{application="guard",status="not_applicable", instance="policy-xacml-pdp:6969", job="xacml-pdp-metrics"}  1
    ValidatePrometheusMetric   pdpx_policy_decisions_total{application="monitoring",status="permit", instance="policy-xacml-pdp:6969", job="xacml-pdp-metrics"}  2
    ValidatePrometheusMetric   pdpx_policy_decisions_total{application="naming",status="permit", instance="policy-xacml-pdp:6969", job="xacml-pdp-metrics"}  1

*** Keywords ***
ValidatePrometheusMetric
    [Arguments]  ${url}  ${expectedLimit}
    [Documentation]  Check that the policy execution is under X limit
    ${resp}=  QueryPrometheus  ${url}
    ${actualValue}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    Should Be True   ${actualValue} <= ${expectedLimit}
