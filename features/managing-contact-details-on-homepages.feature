Feature: managing contact details on home pages
  As an editor
  I want to be able to choose which contacts to show on an org page and control their sort order
  So I can show the most important ones first and not show the less important ones at all

  As an editor
  I want to be able to choose which offices to show on an world org page and control their sort order
  So I can show the most important ones first and not show the less important ones at all

  Background:
    Given I am a GDS editor

  Scenario: Arranging contacts for an organisation
    Given there is an organisation with some contacts on its home page
    When I add a new contact to be featured on the home page of the organisation
    And I reorder the contacts to highlight my new contact
    Then I see the contacts in my specified order including the new one on the home page of the organisation

  Scenario: Removing contacts from the homage page of an organisation
    Given there is an organisation with some contacts on its home page
    When I decide that one of the contacts no longer belongs on the home page
    Then that contact is no longer visible on the home page of the organisation

  Scenario: Arranging offices for a worldwide organisation
    Given there is a worldwide organisation with some offices on its home page
    When I add a new office to be featured on the home page of the worldwide organisation
    And I reorder the offices to highlight my new office
    Then I see the offices in my specified order including the new one under the main office on the home page of the worldwide organisation

  Scenario: Removing offices from the homage page of a worldwide organisation
    Given there is a worldwide organisation with some offices on its home page
    When I decide that one of the offices no longer belongs on the home page
    Then that office is no longer visible on the home page of the worldwide organisation

