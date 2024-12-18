package action

import rego.v1

# By default, deny requests.
default allow := false


# Allow the action if admin role is granted permission to perform the action.
allow if {
    some i
    data.action.user_roles[input.user][i] == role
    some j
    data.action.role_permissions[role].actions[j] == input.action
    some k
    data.action.role_permissions[role].resources[k] == input.type
}
#       * Rego comparison to other systems: https://www.openpolicyagent.org/docs/latest/comparison-to-other-systems/
#       * Rego Iteration: https://www.openpolicyagent.org/docs/latest/#iteration


