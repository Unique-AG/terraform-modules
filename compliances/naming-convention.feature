Feature: Resources naming convention


Scenario: Ensure that the Resource Group name follows the naming convention
    Given I have azurerm_resource_group defined
    Then it must contain name
    And its value must match the "^rg\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the virtual network name follows the naming convention
    Given I have azurerm_virtual_network defined
    Then it must contain name
    And its value must match the "^vnet\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the azure kubernetes service name follows the naming convention
    Given I have azurerm_kubernetes_cluster defined
    Then it must contain name
    And its value must match the "^aks\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the app service plan name follows the naming convention
    Given I have azurerm_service_plan defined
    Then it must contain name
    And its value must match the "^plan\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the app service name follows the naming convention
    Given I have azurerm_windows_web_app defined
    Then it must contain name
    And its value must match the "^app\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the app insight name follows the naming convention
    Given I have azurerm_application_insights defined
    Then it must contain name
    And its value must match the "^appi\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the cdn frontdoor profile name follows the naming convention
    Given I have azurerm_application_insights defined
    Then it must contain name
    And its value must match the "^cdnp\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex

Scenario: Ensure that the cdn frontdoor endpoint name follows the naming convention
    Given I have azurerm_application_insights defined
    Then it must contain name
    And its value must match the "^cdne\-[a-zA-Z0-9_\-]+\-prod\-eus\-[0-9]+$" regex
