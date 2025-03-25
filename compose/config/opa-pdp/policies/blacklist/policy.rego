package blacklist
import future.keywords.in
import rego.v1

# Define a rule to check if the operation should be allowed
module_allow[module] := false if {
    some module in input.vfmodule
    not validate(module)
}

module_allow[module] := true if{
        some module in input.vfmodule
    validate(module)
}

validate(module) if {
        module in data.node.blacklist.blacklist
}
