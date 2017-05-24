#! /bin/bash


echo "Pushing default policies"

# Sometimes brmsgw gets an error when trying to retrieve the policies on initial push,
# so for the BRMS policies we will do a push, then delete from the pdp group, then push again.
# Second push should be successful.

curl -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.vFirewall",
  "policyType": "MicroService"
}' 'http://pdp:8081/pdp/api/pushPolicy'

sleep 2

curl -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.vLoadBalancer",
  "policyType": "MicroService"
}' 'http://pdp:8081/pdp/api/pushPolicy' 

sleep 2
curl -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvLBDemoPolicy",
  "policyType": "BRMS_Param"
}' 'http://pdp:8081/pdp/api/pushPolicy'

sleep 2

curl -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvFWDemoPolicy",
  "policyType": "BRMS_Param"
}' 'http://pdp:8081/pdp/api/pushPolicy'

sleep 2

curl -X DELETE --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
"pdpGroup": "default",
"policyComponent": "PDP",
"policyName": "com.Config_BRMS_Param_BRMSParamvFWDemoPolicy.1.xml"
}' 'http://pdp:8081/pdp/api/deletePolicy'



curl -X DELETE --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
"pdpGroup": "default",
"policyComponent": "PDP",
"policyName": "com.Config_BRMS_Param_BRMSParamvLBDemoPolicy.1.xml"
}' 'http://pdp:8081/pdp/api/deletePolicy'

sleep 2
curl -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvLBDemoPolicy",
  "policyType": "BRMS_Param"
}' 'http://pdp:8081/pdp/api/pushPolicy'

sleep 2

curl -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHJlc3Q6M2MwbXBVI2gwMUBOMWMz' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvFWDemoPolicy",
  "policyType": "BRMS_Param"
}' 'http://pdp:8081/pdp/api/pushPolicy'

