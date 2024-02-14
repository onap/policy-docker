Feature: ACM migration workflow
  # Verifies ACM migration of instance from one AC definition to another

  Scenario: ACM Health check should be up
    When the acm health check endpoint is invoked "/onap/policy/clamp/acm/health"
    Then the response status code should be 200

  Scenario Outline: Verify the ACM commissioning works
    When the ACM commissioning endpoint "/onap/policy/clamp/acm/v2/compositions" is invoked with "<AcDefinitionFile>" "<isMigration>"
    Then the response status code should be 201
    Examples:
      | AcDefinitionFile                                                   | isMigration |
      | src/test/resources/data/acelement-usecase2.json  | false       |

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

  Scenario Outline: Commission the AC definition file for migration
    When the ACM commissioning endpoint "/onap/policy/clamp/acm/v2/compositions" is invoked with "<AcDefinitionFile>" "<isMigration>"
    Then the response status code should be 201
    Examples:
      | AcDefinitionFile                                                   | isMigration |
      | src/test/resources/data/acelement-usecase2.json  | true        |

  Scenario Outline: Prime the second AC definition to the participants
    When the ACM participants are primed "/onap/policy/clamp/acm/v2/compositions/{compositionId}" "<isMigration>"
    Then the response status code should be 202
    Examples:
      | isMigration |
      | true        |

  Scenario Outline: Wait until all the participants are primed
    When the ACM composition is fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "PRIMED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}" "<isMigration>"
    Examples:
      | isMigration |
      | true        |

  Scenario Outline: Migrate the existing instance to the new AC definition
    When the ACM instance is migrated "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances" with "<AcMigrationFile>"
    Then the response status code should be 200
    Examples:
      | AcMigrationFile                                                   |
      | src/test/resources/data/AcMigrateInstance.json  |

  Scenario Outline: Wait until all the AC elements are migrated
    When the AC instance is fetched "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Then the response status code should be 200
    Then Wait and retry until the response contains the keyword "DEPLOYED" "/onap/policy/clamp/acm/v2/compositions/{compositionId}/instances/{instanceId}" "<isMigration>"
    Examples:
      | isMigration |
      | true        |