#! /bin/bash
# Copyright 2018 AT&T Intellectual Property. All rights reserved
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#########################################Upload BRMS Param Template##########################################

echo "Upload BRMS Param Template"

sleep 2

wget -O cl-amsterdam-template.drl https://git.onap.org/policy/drools-applications/plain/controlloop/templates/archetype-cl-amsterdam/src/main/resources/archetype-resources/src/main/resources/__closedLoopControlName__.drl

sleep 2

curl -k -v --silent -X POST --header 'Content-Type: multipart/form-data' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -F "file=@cl-amsterdam-template.drl" -F "importParametersJson={\"serviceName\":\"ClosedLoopControlName\",\"serviceType\":\"BRMSPARAM\"}" 'https://pdp:8081/pdp/api/policyEngineImport' 

echo "PRELOAD_POLICIES is $PRELOAD_POLICIES"

if [ "$PRELOAD_POLICIES" == "false" ]; then
    exit 0
fi

#########################################Create BRMS Param policies##########################################

echo "Create BRMSParam Operational Policies"

sleep 2

echo "Create BRMSParamvFirewall Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyConfigType": "BRMS_PARAM",
	"policyName": "com.BRMSParamvFirewall",
	"policyDescription": "BRMS Param vFirewall policy",
	"policyScope": "com",
	"attributes": {
		"MATCHING": {
	    	"controller" : "amsterdam"
	    },
		"RULE": {
			"templateName": "ClosedLoopControlName",
			"closedLoopControlName": "ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a",
			"controlLoopYaml": "controlLoop%3A%0D%0A++version%3A+2.0.0%0D%0A++controlLoopName%3A+ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a%0D%0A++trigger_policy%3A+unique-policy-id-1-modifyConfig%0D%0A++timeout%3A+1200%0D%0A++abatement%3A+false%0D%0A+%0D%0Apolicies%3A%0D%0A++-+id%3A+unique-policy-id-1-modifyConfig%0D%0A++++name%3A+modify+packet+gen+config%0D%0A++++description%3A%0D%0A++++actor%3A+APPC%0D%0A++++recipe%3A+ModifyConfig%0D%0A++++target%3A%0D%0A++++++%23+TBD+-+Cannot+be+known+until+instantiation+is+done%0D%0A++++++resourceID%3A+Eace933104d443b496b8.nodes.heat.vpg%0D%0A++++++type%3A+VNF%0D%0A++++retry%3A+0%0D%0A++++timeout%3A+300%0D%0A++++success%3A+final_success%0D%0A++++failure%3A+final_failure%0D%0A++++failure_timeout%3A+final_failure_timeout%0D%0A++++failure_retries%3A+final_failure_retries%0D%0A++++failure_exception%3A+final_failure_exception%0D%0A++++failure_guard%3A+final_failure_guard"
		}
	}
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 2

echo "Create BRMSParamvDNS Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyConfigType": "BRMS_PARAM",
	"policyName": "com.BRMSParamvDNS",
	"policyDescription": "BRMS Param vDNS policy",
	"policyScope": "com",
	"attributes": {
		"MATCHING": {
	    	"controller" : "amsterdam"
	    },
		"RULE": {
			"templateName": "ClosedLoopControlName",
			"closedLoopControlName": "ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3",
			"controlLoopYaml": "controlLoop%3A%0D%0A++version%3A+2.0.0%0D%0A++controlLoopName%3A+ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3%0D%0A++trigger_policy%3A+unique-policy-id-1-scale-up%0D%0A++timeout%3A+1200%0D%0A++abatement%3A+false%0D%0Apolicies%3A%0D%0A++-+id%3A+unique-policy-id-1-scale-up%0D%0A++++name%3A+Create+a+new+VF+Module%0D%0A++++description%3A%0D%0A++++actor%3A+SO%0D%0A++++recipe%3A+VF+Module+Create%0D%0A++++target%3A%0D%0A++++++type%3A+VNF%0D%0A++++retry%3A+0%0D%0A++++timeout%3A+1200%0D%0A++++success%3A+final_success%0D%0A++++failure%3A+final_failure%0D%0A++++failure_timeout%3A+final_failure_timeout%0D%0A++++failure_retries%3A+final_failure_retries%0D%0A++++failure_exception%3A+final_failure_exception%0D%0A++++failure_guard%3A+final_failure_guard"
		}
	}
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 2

echo "Create BRMSParamVOLTE Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyConfigType": "BRMS_PARAM",
	"policyName": "com.BRMSParamVOLTE",
	"policyDescription": "BRMS Param VOLTE policy",
	"policyScope": "com",
	"attributes": {
		"MATCHING": {
	    	"controller" : "amsterdam"
	    },
		"RULE": {
			"templateName": "ClosedLoopControlName",
			"closedLoopControlName": "ControlLoop-VOLTE-2179b738-fd36-4843-a71a-a8c24c70c55b",
			"controlLoopYaml": "controlLoop%3A%0D%0A++version%3A+2.0.0%0D%0A++controlLoopName%3A+ControlLoop-VOLTE-2179b738-fd36-4843-a71a-a8c24c70c55b%0D%0A++trigger_policy%3A+unique-policy-id-1-restart%0D%0A++timeout%3A+3600%0D%0A++abatement%3A+false%0D%0A+%0D%0Apolicies%3A%0D%0A++-+id%3A+unique-policy-id-1-restart%0D%0A++++name%3A+Restart+the+VM%0D%0A++++description%3A%0D%0A++++actor%3A+VFC%0D%0A++++recipe%3A+Restart%0D%0A++++target%3A%0D%0A++++++type%3A+VM%0D%0A++++retry%3A+3%0D%0A++++timeout%3A+1200%0D%0A++++success%3A+final_success%0D%0A++++failure%3A+final_failure%0D%0A++++failure_timeout%3A+final_failure_timeout%0D%0A++++failure_retries%3A+final_failure_retries%0D%0A++++failure_exception%3A+final_failure_exception%0D%0A++++failure_guard%3A+final_failure_guard"
		}
	}
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 2

echo "Create BRMSParamvCPE Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyConfigType": "BRMS_PARAM",
	"policyName": "com.BRMSParamvCPE",
	"policyDescription": "BRMS Param vCPE policy",
	"policyScope": "com",
	"attributes": {
	    "MATCHING": {
	    	"controller" : "amsterdam"
	    },
		"RULE": {
			"templateName": "ClosedLoopControlName",
			"closedLoopControlName": "ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e",
			"controlLoopYaml": "controlLoop%3A%0D%0A++version%3A+2.0.0%0D%0A++controlLoopName%3A+ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e%0D%0A++trigger_policy%3A+unique-policy-id-1-restart%0D%0A++timeout%3A+3600%0D%0A++abatement%3A+true%0D%0A+%0D%0Apolicies%3A%0D%0A++-+id%3A+unique-policy-id-1-restart%0D%0A++++name%3A+Restart+the+VM%0D%0A++++description%3A%0D%0A++++actor%3A+APPC%0D%0A++++recipe%3A+Restart%0D%0A++++target%3A%0D%0A++++++type%3A+VM%0D%0A++++retry%3A+3%0D%0A++++timeout%3A+1200%0D%0A++++success%3A+final_success%0D%0A++++failure%3A+final_failure%0D%0A++++failure_timeout%3A+final_failure_timeout%0D%0A++++failure_retries%3A+final_failure_retries%0D%0A++++failure_exception%3A+final_failure_exception%0D%0A++++failure_guard%3A+final_failure_guard"
		}
	}
}' 'https://pdp:8081/pdp/api/createPolicy'

#########################################Create Micro Service Config policies##########################################

echo "Create MicroService Config Policies"

sleep 2

echo "Create MicroServicevFirewall Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"configBody": "{ \"service\": \"tca_policy\", \"location\": \"SampleServiceLocation\", \"uuid\": \"test\", \"policyName\": \"MicroServicevFirewall\", \"description\": \"MicroService vFirewall Policy\", \"configName\": \"SampleConfigName\", \"templateVersion\": \"OpenSource.version.1\", \"version\": \"1.1.0\", \"priority\": \"1\", \"policyScope\": \"resource=SampleResource,service=SampleService,type=SampleType,closedLoopControlName=ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a\", \"riskType\": \"SampleRiskType\", \"riskLevel\": \"1\", \"guard\": \"False\", \"content\": { \"tca_policy\": { \"domain\": \"measurementsForVfScaling\", \"metricsPerEventName\": [{ \"eventName\": \"vFirewallBroadcastPackets\", \"controlLoopSchemaType\": \"VNF\", \"policyScope\": \"DCAE\", \"policyName\": \"DCAE.Config_tca-hi-lo\", \"policyVersion\": \"v0.0.1\", \"thresholds\": [{ \"closedLoopControlName\": \"ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a\", \"version\": \"1.0.2\", \"fieldPath\": \"$.event.measurementsForVfScalingFields.vNicUsageArray[*].receivedTotalPacketsDelta\", \"thresholdValue\": 300, \"direction\": \"LESS_OR_EQUAL\", \"severity\": \"MAJOR\", \"closedLoopEventStatus\": \"ONSET\" }, { \"closedLoopControlName\": \"ControlLoop-vFirewall-d0a1dfc6-94f5-4fd4-a5b5-4630b438850a\", \"version\": \"1.0.2\", \"fieldPath\": \"$.event.measurementsForVfScalingFields.vNicUsageArray[*].receivedTotalPacketsDelta\", \"thresholdValue\": 700, \"direction\": \"GREATER_OR_EQUAL\", \"severity\": \"CRITICAL\", \"closedLoopEventStatus\": \"ONSET\" } ] }] } } }",
	"policyConfigType": "MicroService",
	"policyName": "com.MicroServicevFirewall",
	"onapName": "DCAE"
}' 'https://pdp:8081/pdp/api/createPolicy'


sleep 2

echo "Create MicroServicevDNS Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"configBody": "{ \"service\": \"tca_policy\", \"location\": \"SampleServiceLocation\", \"uuid\": \"test\", \"policyName\": \"MicroServicevDNS\", \"description\": \"MicroService vDNS Policy\", \"configName\": \"SampleConfigName\", \"templateVersion\": \"OpenSource.version.1\", \"version\": \"1.1.0\", \"priority\": \"1\", \"policyScope\": \"resource=SampleResource,service=SampleService,type=SampleType,closedLoopControlName=ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3\", \"riskType\": \"SampleRiskType\", \"riskLevel\": \"1\", \"guard\": \"False\", \"content\": { \"tca_policy\": { \"domain\": \"measurementsForVfScaling\", \"metricsPerEventName\": [{ \"eventName\": \"vLoadBalancer\", \"controlLoopSchemaType\": \"VM\", \"policyScope\": \"DCAE\", \"policyName\": \"DCAE.Config_tca-hi-lo\", \"policyVersion\": \"v0.0.1\", \"thresholds\": [{ \"closedLoopControlName\": \"ControlLoop-vDNS-6f37f56d-a87d-4b85-b6a9-cc953cf779b3\", \"version\": \"1.0.2\", \"fieldPath\": \"$.event.measurementsForVfScalingFields.vNicUsageArray[*].receivedTotalPacketsDelta\", \"thresholdValue\": 300, \"direction\": \"GREATER_OR_EQUAL\", \"severity\": \"CRITICAL\", \"closedLoopEventStatus\": \"ONSET\" }] }] } } }",
	"policyConfigType": "MicroService",
	"policyName": "com.MicroServicevDNS",
	"onapName": "DCAE"
}' 'https://pdp:8081/pdp/api/createPolicy'


sleep 2

echo "Create MicroServicevCPE Policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"configBody": "{ \"service\": \"tca_policy\", \"location\": \"SampleServiceLocation\", \"uuid\": \"test\", \"policyName\": \"MicroServicevCPE\", \"description\": \"MicroService vCPE Policy\", \"configName\": \"SampleConfigName\", \"templateVersion\": \"OpenSource.version.1\", \"version\": \"1.1.0\", \"priority\": \"1\", \"policyScope\": \"resource=SampleResource,service=SampleService,type=SampleType,closedLoopControlName=ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e\", \"riskType\": \"SampleRiskType\", \"riskLevel\": \"1\", \"guard\": \"False\", \"content\": { \"tca_policy\": { \"domain\": \"measurementsForVfScaling\", \"metricsPerEventName\": [{ \"eventName\": \"Measurement_vGMUX\", \"controlLoopSchemaType\": \"VNF\", \"policyScope\": \"DCAE\", \"policyName\": \"DCAE.Config_tca-hi-lo\", \"policyVersion\": \"v0.0.1\", \"thresholds\": [{ \"closedLoopControlName\": \"ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e\", \"version\": \"1.0.2\", \"fieldPath\": \"$.event.measurementsForVfScalingFields.additionalMeasurements[*].arrayOfFields[0].value\", \"thresholdValue\": 0, \"direction\": \"EQUAL\", \"severity\": \"MAJOR\", \"closedLoopEventStatus\": \"ABATED\" }, { \"closedLoopControlName\": \"ControlLoop-vCPE-48f0c2c3-a172-4192-9ae3-052274181b6e\", \"version\": \"1.0.2\", \"fieldPath\": \"$.event.measurementsForVfScalingFields.additionalMeasurements[*].arrayOfFields[0].value\", \"thresholdValue\": 0, \"direction\": \"GREATER\", \"severity\": \"CRITICAL\", \"closedLoopEventStatus\": \"ONSET\" }] }] } } }",
	"policyConfigType": "MicroService",
	"policyName": "com.MicroServicevCPE",
	"onapName": "DCAE"
}' 'https://pdp:8081/pdp/api/createPolicy'


#########################################Creating Decision Guard policy######################################### 

sleep 2

echo "Creating Decision Guard policy"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{ 
	"policyClass": "Decision", 
	"policyName": "com.AllPermitGuard", 
	"policyDescription": "Testing all Permit YAML Guard Policy", 
	"ecompName": "PDPD", 
	"ruleProvider": "GUARD_YAML", 
	"attributes": { 
		"MATCHING": { 
			"actor": ".*", 
			"recipe": ".*", 
			"targets": ".*", 
			"clname": ".*", 
			"limit": "10", 
			"timeWindow": "1", 
			"timeUnits": "minute", 
			"guardActiveStart": "00:00:01-05:00", 
			"guardActiveEnd": "00:00:00-05:00" 
		} 
	} 
}' 'https://pdp:8081/pdp/api/createPolicy'

#########################################Push Decision policy#########################################

sleep 2

echo "Push Decision policy" 
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{ 
  "pdpGroup": "default", 
  "policyName": "com.AllPermitGuard", 
  "policyType": "DECISION" 
}' 'https://pdp:8081/pdp/api/pushPolicy'

#########################################Pushing BRMS Param policies##########################################

echo "Pushing BRMSParam Operational policies"

sleep 2

echo "pushPolicy : PUT : com.BRMSParamvFirewall"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvFirewall",
  "policyType": "BRMS_Param"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 2

echo "pushPolicy : PUT : com.BRMSParamvDNS"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvDNS",
  "policyType": "BRMS_Param"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 2

echo "pushPolicy : PUT : com.BRMSParamVOLTE"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamVOLTE",
  "policyType": "BRMS_Param"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 2

echo "pushPolicy : PUT : com.BRMSParamvCPE"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.BRMSParamvCPE",
  "policyType": "BRMS_Param"
}' 'https://pdp:8081/pdp/api/pushPolicy'

#########################################Pushing MicroService Config policies##########################################

echo "Pushing MicroService Config policies"

sleep 2

echo "pushPolicy : PUT : com.MicroServicevFirewall"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.MicroServicevFirewall",
  "policyType": "MicroService"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 10

echo "pushPolicy : PUT : com.MicroServicevDNS"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.MicroServicevDNS",
  "policyType": "MicroService"
}' 'https://pdp:8081/pdp/api/pushPolicy' 

sleep 10

echo "pushPolicy : PUT : com.MicroServicevCPE"
curl -k -v --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.MicroServicevCPE",
  "policyType": "MicroService"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 10

#########################################Creating Decision Raw policy######################################### 

echo "Create SectorNaPolicy Policy"

curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyName": "com.SectorNaPolicy",  
	"policyClass": "Decision",  
	"ruleProvider": "Raw",  
	"rawXacmlPolicy": "&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:sector_na:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;        Policy to determine if the Sectors are NA    &lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Policy Internal&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:subject:subject-id&quot; Category=&quot;urn:oasis:names:tc:xacml:1.0:subject-category:access-subject&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Energy Savings&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:resource:domain&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Sector Check&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:action:action-id&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:action&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;/Target&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:ran_energy:sector_na:rule&quot;&gt;&lt;Description&gt;            Sector is not applicable        &lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:or&quot;&gt;&lt;Description&gt; If any of the three conditions below are true; all the cells in the Sector should be categorized as unworkable &lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-equal&quot;&gt;&lt;Description&gt; No B14 or B17 cells with 10 BW in the Sector &lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;cellCategory&apos; and (text() = &apos;B17&apos; or text() = &apos;B12&apos;)]/../*[local-name()=&apos;spec&apos;]/*[local-name()=&apos;dlBw&apos; and text() = &apos;10&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;0&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-equal&quot;&gt;&lt;Description&gt; No B2 or B4 cells in the Sector &lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;cellCategory&apos; and (text() = &apos;B2&apos; or text() = &apos;B4&apos;)]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;0&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:not&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:and&quot;&gt;&lt;Description&gt; Sector has &gt;= 3 Cells not counting B14 or WLL and all Cells have same Azimuth&lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-greater-than&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;cellCategory&apos; and (text() != &apos;B14&apos; and text() != &apos;WLL&apos;)]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;2&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:any-of-all&quot;&gt;&lt;Description&gt; &quot;Same Azimuth&quot; condition is applied to all cells in that sector&lt;/Description&gt;&lt;Function FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot; /&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;spec&apos;]/*[local-name()=&apos;azimuth&apos;]/text()&quot; /&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;spec&apos;]/*[local-name()=&apos;azimuth&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;"
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 2

echo "Create SectorTagsPolicy Policy"

curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyName": "com.SectorTagsPolicy",  
	"policyClass": "Decision",  
	"ruleProvider": "Raw",  
	"rawXacmlPolicy": "&lt;PolicySet xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:first-applicable&quot; PolicySetId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:sector_tagging:policyset&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;PolicySet for Sector tagging.&lt;/Description&gt;&lt;Target&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Policy Internal&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:subject:subject-id&quot; Category=&quot;urn:oasis:names:tc:xacml:1.0:subject-category:access-subject&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Energy Savings&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:resource:domain&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Sector Tagging&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:action:action-id&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:action&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;/Target&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:sector_issue:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;Not enough coverage or capacity cells. Coverage less than 2 and Capacity less than 1&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:no_coverage_cell:rule&quot;&gt;&lt;Description&gt;Not enough coverage or capacity cells. Coverage less than 2 and Capacity less than 1&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:not&quot;&gt;&lt;Description&gt;Negating&lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:and&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-greater-than&quot;&gt;&lt;Description&gt;Sector has atleast 2 Coverage cells&lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;status&apos;]/*[local-name()=&apos;cellType&apos; and text()=&apos;Coverage Cell&apos;]&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;1&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-greater-than&quot;&gt;&lt;Description&gt;Sector has atleast 1 Capacity cells&lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;status&apos;]/*[local-name()=&apos;cellType&apos; and text()=&apos;Capacity Cell&apos;]&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;0&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:30_bw_sector:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;Sector Tag for 30 BW or 25&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:no_coverage_cell:rule&quot;&gt;&lt;Description&gt;Combined coverage bandwidth if 25 or 30&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:or&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;//*[local-name()=&apos;combinedCoverageBw&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;25&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;//*[local-name()=&apos;combinedCoverageBw&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;30&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:20_bw_sector:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;Sector Tag for 20 BW&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:no_coverage_cell:rule&quot;&gt;&lt;Description&gt;Combined coverage bandwidth is 20&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:or&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;//*[local-name()=&apos;combinedCoverageBw&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;20&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:15_bw_sector:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;SectorTag for 15 BW&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:no_coverage_cell:rule&quot;&gt;&lt;Description&gt;Combined coverage bandwidth is 15&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:or&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;//*[local-name()=&apos;combinedCoverageBw&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;15&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:insufficient_bw_sector:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;Sector has coverage and capacity cells but insufficient BW&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:no_coverage_cell:rule&quot;&gt;&lt;Description&gt;This is the default case. If none of the above cases match, then the sector gets classified as insufficent BW.&lt;/Description&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;/PolicySet&gt;"
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 2

echo "Create eNodebNAPolicy Policy"

curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyName": "com.eNodebNAPolicy",  
	"policyClass": "Decision",  
	"ruleProvider": "Raw",  
	"rawXacmlPolicy": "&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:unworkable_enodeb:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;Policy for enodeb Unworkable&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Policy Internal&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:subject:subject-id&quot; Category=&quot;urn:oasis:names:tc:xacml:1.0:subject-category:access-subject&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Energy Savings&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:resource:domain&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Enodeb Check&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:action:action-id&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:action&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;/Target&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:dul_mrbs_check:rule&quot;&gt;&lt;Description&gt;Check if the eNodeB is of type DUL or mRBS&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-regexp-match&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;DUL.*|mRBS.*&lt;/AttributeValue&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;spec&apos;]/*[local-name()=&apos;ericsson&apos;]/*[local-name()=&apos;duType&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:three_cell_site:rule&quot;&gt;&lt;Description&gt;Check if it is the case that eNodeB does not have more than or equal to 3 cells not counting B14, WLL or DAS/IB&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:not&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-greater-than&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;sectors&apos;]/*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;cellCategory&apos; and (text() != &apos;B14&apos; and text() != &apos;WLL&apos; and text() != &apos;DAS/IB&apos;)]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;2&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:small_cell_check:rule&quot;&gt;&lt;Description&gt;Check if the eNodeB has small cells&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-regexp-match&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;..S.*&lt;/AttributeValue&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;spec&apos;]/*[local-name()=&apos;commonId&apos;]/text()&quot; /&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:b17_b12_check:rule&quot;&gt;&lt;Description&gt;It is not the case that Enodeb has B17 or B12 cells&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:not&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-greater-than&quot;&gt;&lt;Description&gt; Enodeb has B17 or B12 cells &lt;/Description&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()=&apos;sectors&apos;]/*[local-name()=&apos;cells&apos;]/*[local-name()=&apos;cellCategory&apos; and (text() = &apos;B12&apos; or text() = &apos;B17&apos;)]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;0&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;"
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 2

echo "Create cellTagsPolicy Policy"

curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/html' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
	"policyName": "com.cellTagsPolicy",  
	"policyClass": "Decision",  
	"ruleProvider": "Raw",  
	"rawXacmlPolicy": "&lt;PolicySet xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; PolicyCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:policy-combining-algorithm:first-applicable&quot; PolicySetId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:cell_tagging:policyset&quot; Version=&quot;1&quot;&gt;&lt;Description&gt;PolicySet for Cell Tagging.&lt;/Description&gt;&lt;Target&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Policy Internal&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:subject:subject-id&quot; Category=&quot;urn:oasis:names:tc:xacml:1.0:subject-category:access-subject&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Energy Savings&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:resource:domain&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;AnyOf&gt;&lt;AllOf&gt;&lt;Match MatchId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;Cell Tagging&lt;/AttributeValue&gt;&lt;AttributeDesignator AttributeId=&quot;urn:oasis:names:tc:xacml:1.0:action:action-id&quot; Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:action&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; /&gt;&lt;/Match&gt;&lt;/AllOf&gt;&lt;/AnyOf&gt;&lt;/Target&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:unworkable_cell:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot; xsi:schemaLocation=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd&quot;&gt;&lt;Description&gt;Policy for Cells Unworkable&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:unworkable_cell:rule&quot;&gt;&lt;Description&gt;Cell iS B14, B46 or WLL or DAS/IB&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()='cellCategory' and (text() = 'B14' or text() = 'B46' or text() = 'WLL' or text() = 'DAS/IB')]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;1&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:coverage_cell:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot; xsi:schemaLocation=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd&quot;&gt;&lt;Description&gt;Cell is B17 or B12&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:coverage_cell:rule&quot;&gt;&lt;Description&gt;Cell iS B17 or B12&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()='cellCategory' and (text() = 'B12' or text() = 'B17')]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;1&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:capacity_cell:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot; xsi:schemaLocation=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd&quot;&gt;&lt;Description&gt;Policy for Capacity Cells&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:capacity_cell:rule&quot;&gt;&lt;Description&gt;The cell category is either B29 or B30 or B5 or AWS&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:integer-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-bag-size&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()='cellCategory' and (text() = 'B29' or text() = 'B30' or text() = 'B5' or text() = 'AWS')]/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#integer&quot;&gt;1&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:highest_ranked_cell:rule&quot;&gt;&lt;Description&gt;Cell is not highest ranked. Note: Any cell (not just B2 or B4) which reaches this point, and is not highest ranked will pass.&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()='isMaxmbRank']/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;0&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;Policy xmlns=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17&quot; xmlns:xsi=&quot;http://www.w3.org/2001/XMLSchema-instance&quot; PolicyId=&quot;urn:oasis:names:tc:xacml:2.0:ran_energy:coverage_cell:policy&quot; RuleCombiningAlgId=&quot;urn:oasis:names:tc:xacml:1.0:rule-combining-algorithm:first-applicable&quot; Version=&quot;1&quot; xsi:schemaLocation=&quot;urn:oasis:names:tc:xacml:3.0:core:schema:wd-17 http://docs.oasis-open.org/xacml/3.0/xacml-core-v3-schema-wd-17.xsd&quot;&gt;&lt;Description&gt;&lt;/Description&gt;&lt;PolicyDefaults&gt;&lt;XPathVersion&gt;http://www.w3.org/TR/1999/Rec-xpath-19991116&lt;/XPathVersion&gt;&lt;/PolicyDefaults&gt;&lt;Target/&gt;&lt;Rule Effect=&quot;Permit&quot; RuleId=&quot;urn:oasis:names:tc:xacml:2.0:coverage_cell:rule&quot;&gt;&lt;Description&gt;Cell is highest ranked. Note: Any cell (not just B2 or B4) that reaches this point, and is highest ranked will pass&lt;/Description&gt;&lt;Condition&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-equal&quot;&gt;&lt;Apply FunctionId=&quot;urn:oasis:names:tc:xacml:1.0:function:string-one-and-only&quot;&gt;&lt;AttributeSelector Category=&quot;urn:oasis:names:tc:xacml:3.0:attribute-category:resource&quot; DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot; MustBePresent=&quot;false&quot; ContextSelectorId=&quot;urn:oasis:names:tc:xacml:3.0:content-selector&quot; Path=&quot;*[local-name()='isMaxmbRank']/text()&quot; /&gt;&lt;/Apply&gt;&lt;AttributeValue DataType=&quot;http://www.w3.org/2001/XMLSchema#string&quot;&gt;1&lt;/AttributeValue&gt;&lt;/Apply&gt;&lt;/Condition&gt;&lt;/Rule&gt;&lt;/Policy&gt;&lt;/PolicySet&gt;"
}' 'https://pdp:8081/pdp/api/createPolicy'

sleep 10

#########################################Pushing Decision Raw policy######################################### 

echo "pushPolicy : PUT : com.SectorNaPolicy"
curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.SectorNaPolicy",
  "policyType": "Decision"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 10

echo "pushPolicy : PUT : com.SectorTagsPolicy"
curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.SectorTagsPolicy",
  "policyType": "Decision"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 10

echo "pushPolicy : PUT : com.eNodebNAPolicy"
curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.eNodebNAPolicy",
  "policyType": "Decision"
}' 'https://pdp:8081/pdp/api/pushPolicy'

sleep 10

echo "pushPolicy : PUT : com.cellTagsPolicy"
curl -k --silent -X PUT --header 'Content-Type: application/json' --header 'Accept: text/plain' --header 'ClientAuth: cHl0aG9uOnRlc3Q=' --header 'Authorization: Basic dGVzdHBkcDphbHBoYTEyMw==' --header 'Environment: TEST' -d '{
  "pdpGroup": "default",
  "policyName": "com.cellTagsPolicy",
  "policyType": "Decision"
}' 'https://pdp:8081/pdp/api/pushPolicy'

