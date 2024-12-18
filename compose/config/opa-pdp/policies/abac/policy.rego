package abac

import rego.v1

default allow := false

allow if {
 viewable_sensor_data
 action_is_read
}

action_is_read if "read" in input.actions

viewable_sensor_data contains view_data if {
 some sensor_data in data.abac.sensor_data
 sensor_data.timestamp >= input.time_period.from
 sensor_data.timestamp < input.time_period.to

 view_data := {datatype: sensor_data[datatype] | datatype in input.datatypes}
}
