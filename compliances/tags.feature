Feature: Verify tags in resources
  @ignore_azurerm_private_dns_a_record.*
  Scenario: Ensure all resources have tags
    Given I have resource that supports tags defined
    Then it must contain tags
    And its value must not be null


  @ignore_azurerm_private_dns_a_record.*
  Scenario: Ensure all resources have terraform tag
    Given I have resource that supports tags defined
    Then it must contain tags
    Then it must contain "ManagedBy"
    And its value must match the "TERRAFORM" regex
