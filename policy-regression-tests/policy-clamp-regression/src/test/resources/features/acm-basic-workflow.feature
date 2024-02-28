Feature: ACM basic workflow
  # Verifies ACM basic workflows commission, prime, de-prime, instantiate, deploy, update-properties, undeploy, uninstantiate and delete.

  Scenario: ACM Health check should be up
    When the acm health check endpoint is invoked "/onap/policy/clamp/acm/health"
    Then the response status code should be 200

  Scenario Outline: Verify the ACM commissioning works
    When the ACM commissioning endpoint "/onap/policy/clamp/acm/v2/compositions" is invoked with "<AcDefinitionFile>" "<isMigration>"
    Then the response status code should be 201
    Examples:
      | AcDefinitionFile                                                   | isMigration |
      | src/test/resources/data/acelement-usecase1.json  | false       |

  Scenario: Make sure the participants are registered with runtime
    When the register participants endpoint is invoked "/onap/policy/clamp/acm/v2/participants"
    Then the response status code should be 202

  Scenario Outline: Verify the priming is accepted
    When the ACM participants are primed "/onap/policy/clamp/acm/v2/compositions/{compositionId}" "<isMigration>"
    Then the response status code should be 202
    Examples:
      | isMigration |
      | false        |

  Scenario Outline: Wait until all the participants are primed
    When the ACM composition is fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "PRIMED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}" "<isMigration>"
    Examples:
      | isMigration |
      | false        |

  Scenario Outline: Verify AC Instantiation works
    When the ACM instance is created "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances" with "<AcInstantiateFile>"
    Then the response status code should be 201
    Examples:
      | AcInstantiateFile                                             |
      | src/test/resources/data/AcInstantiate.json  |

  Scenario: Verify the AC deployment is accepted
    When the AC instance is deployed "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}"
    Then the response status code should be 202

  Scenario Outline: Wait until all the AC elements are deployed
    When the AC instance is fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "DEPLOYED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Examples:
      | isMigration |
      | false        |

  Scenario Outline: Update instance property after deployment
    When the AC instance property is updated "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances" "<AcUpdatePropertyFile>"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "DEPLOYED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Then the response should contain the updated properties "acm_element_policy_updated" "test"
    Examples:
      | AcUpdatePropertyFile                                             | isMigration |
      | src/test/resources/data/AcUpdateProperty.json  | false       |

  Scenario: Verify AC instance undeployment is accepted
    When the AC instance is undeployed "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}"
    Then the response status code should be 202

  Scenario Outline: Wait until all the AC elements are undeployed
    When the AC instance is fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "UNDEPLOYED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Examples:
      | isMigration  |
      | false        |

  Scenario: Verify AC UnInstantiation is accepted
    When the ACM instance is uninstantiated " /onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}"
    Then the response status code should be 202

  Scenario: Wait until the AC instance is uninstatiated
    When all the AC instances are fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances"
    Then the response status code should be 200
    Then Wait and retry until the ac instance list is empty "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances"

  Scenario: Verify the DePriming is accepted
    When the ACM participants are deprimed "/onap/policy/clamp/acm/v2/compositions/{compositionId}"
    Then the response status code should be 202

  Scenario Outline: Wait until all the participants are deprimed
    When the ACM composition is fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "COMMISSIONED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}" "<isMigration>"
    Examples:
      | isMigration |
      | false        |

  Scenario: Verify the deletion of Ac definition
    When the AC definition is deleted "/onap/policy/clamp/acm/v2/compositions/{compositionId}"
    Then the response status code should be 200