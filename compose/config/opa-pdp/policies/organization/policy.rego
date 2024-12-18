package organization

import rego.v1

default allow := false

# organization level access
allow if {
 some acl in data.organization.acls
 acl.user == input.user
 acl.organization == input.organization
 acl.project == input.project
 acl.component == input.component

 some action in acl.actions
 action == input.action
}

# project level access
allow if {
 some acl in data.organization.acls
 acl.user == input.user
 acl.organization == input.organization
 acl.project == input.project

 some action in acl.actions
 action == input.action
}

# component level access
allow if {
 some acl in data.organization.acls
 acl.user == input.user
 acl.organization == input.organization

 some action in acl.actions
 action == input.action
}
