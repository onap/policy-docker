*** Settings ***
Library    OperatingSystem
Resource    common-library.robot

*** Test Cases ***
WaitForPrometheusServer
    [Documentation]  Sleep time to wait for Prometheus server to gather all metrics
    Sleep    1 minute

ValidatePolicyExecutionTimes
    [Documentation]    Validate policy execution times using prometheus metrics
    ValidatePolicyExecution   pdpd_policy_executions_latency_seconds_count{controller="usecases",controlloop="ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3",policy="operational.scaleout:1.0.0",status="SUCCESS", instance="policy-drools-apps:9696", job="drools-apps-metrics"}  1000
    ValidatePolicyExecution   pdpd_policy_deployments_total{state="ACTIVE",operation="deploy",status="SUCCESS", instance="policy-drools-apps:9696", job="drools-apps-metrics"}  3000

