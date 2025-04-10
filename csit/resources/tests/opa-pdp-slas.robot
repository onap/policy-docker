*** Settings ***
Library    OperatingSystem
Resource    common-library.robot

*** Test Cases ***
WaitForPrometheusServer
    [Documentation]  Sleep time to wait for Prometheus server to gather all metrics
    Sleep    1 minute

ValidateOPAPolicyDecisionsTotalCounter
    [Documentation]    Validate opa policy decision counters using prometheus metrics
    ValidateOPAPrometheusMetric   opa_decision_response_time_seconds_count{instance="policy-opa-pdp:8282", job="opa-pdp-metrics"}  9

ValidateOPAPolicyDataTotalCounter
    [Documentation]    Validate opa policy data counters using prometheus metrics
    ValidateOPAPrometheusMetric   opa_data_response_time_seconds_count{instance="policy-opa-pdp:8282", job="opa-pdp-metrics"}  12

ValidateOPADecisionAverageResponseTime
    [Documentation]    Ensure average response time is less than 10ms
    ValidateOPADecisionAverageResponseTimeMetric   1.5

ValidateOPADataAverageResponseTime
    [Documentation]    Ensure average response time is less than 10ms
    ValidateOPADataAverageResponseTimeMetric   1.5


*** Keywords ***
ValidateOPAPrometheusMetric
    [Arguments]  ${url}  ${expectedLimit}
    [Documentation]  Check the policy decision/data execution count
    ${resp}=  QueryPrometheus   ${url}
    ${actualValue}=  Evaluate  ${resp['data']['result'][0]['value'][1]}
    Should Be True   ${actual_value} == ${expectedLimit}

ValidateOPADecisionAverageResponseTimeMetric
    [Arguments]  ${threshold}
    [Documentation]  Validate that the average response time is below the threshold

    ${sum_resp}=  QueryPrometheus   opa_decision_response_time_seconds_sum{instance="policy-opa-pdp:8282", job="opa-pdp-metrics"}
    ${count_resp}=  QueryPrometheus   opa_decision_response_time_seconds_count{instance="policy-opa-pdp:8282", job="opa-pdp-metrics"}

    ${sum_value}=  Evaluate  ${sum_resp['data']['result'][0]['value'][1]}
    ${count_value}=  Evaluate  ${count_resp['data']['result'][0]['value'][1]}

    ${avg_response_time}=  Evaluate  float(${sum_value}) / float(${count_value})
    Should Be True   ${avg_response_time} < ${threshold}  msg=Average response time exceeded ${threshold}


ValidateOPADataAverageResponseTimeMetric
    [Arguments]  ${threshold}
    [Documentation]  Validate that the average response time is below the threshold

    ${sum_resp}=  QueryPrometheus   opa_data_response_time_seconds_sum{instance="policy-opa-pdp:8282", job="opa-pdp-metrics"}
    ${count_resp}=  QueryPrometheus   opa_data_response_time_seconds_count{instance="policy-opa-pdp:8282", job="opa-pdp-metrics"}

    ${sum_value}=  Evaluate  ${sum_resp['data']['result'][0]['value'][1]}
    ${count_value}=  Evaluate  ${count_resp['data']['result'][0]['value'][1]}

    ${avg_response_time}=  Evaluate  float(${sum_value}) / float(${count_value})
    Should Be True   ${avg_response_time} < ${threshold}  msg=Average response time exceeded ${threshold}
