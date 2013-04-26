# encoding: utf-8

Feature: Viewing world location news specific to native language speakers

  @not-quite-as-fake-search
  Scenario: Viewing a published world location news article that is not available in English
    Given a world location "France" exists with a translation for the locale "Français"
    And a published French-only world location news article "Le président Funky arrive en ville" for the world location "France" exists
    When I view the world location "France" in the locale "Français"
    Then I should see the French-only world location news article "Le président Funky arrive en ville"
    And I should be able to read the world location news article "Le président Funky arrive en ville" in the locale "Français"
    When I view the world location "France" in the locale "English"
    Then I should not see the world location news article "Le président Funky arrive en ville" listed
