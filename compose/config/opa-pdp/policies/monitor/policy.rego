package monitor

# Policy allows if a matching threshold is met
result contains output if {
    input.domain = data.node.monitor.domain
    some events  in data.node.monitor.metricsPerEventName
    events.eventName == input.eventName
    events.controlLoopSchemaType == input.controlLoopSchemaType
    events.policyScope == input.policyScope
    events.policyName == input.policyName
    events.policyVersion == input.policyVersion
    some value in events.thresholds
    input.controlname == value.closedLoopControlName
    input.version == value.version
    input.thresholdValue == value.thresholdValue
    output := {
        "severity" : "MAJOR",
        "closedLoopEventStatus" : "ABATED"
        }
}

# Policy allows if a matching threshold is met
result contains output if {
    input.domain = data.node.monitor.domain
    some events  in data.node.monitor.metricsPerEventName
    events.eventName == input.eventName
    events.controlLoopSchemaType == input.controlLoopSchemaType
    events.policyScope == input.policyScope
    events.policyName == input.policyName
    events.policyVersion == input.policyVersion
    some value in events.thresholds
    input.controlname == value.closedLoopControlName
    input.version == value.version
    input.thresholdValue > value.thresholdValue
    output := {
        "severity" : "CRITICAL",
        "closedLoopEventStatus" : "ONSET"
        }
}
