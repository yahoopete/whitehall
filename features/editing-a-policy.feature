Feature: As a policy writer I should be able to edit and save a policy
In order to send the best version of a policy to the departmental editor
A policy writer
Should be able to edit and save draft policies

Scenario: Saving a draft policy
Given I visit the new policy page
When I write and save a policy called "Milk for kids" with body
  """
  Calcium is good for growing bones!
  """
Then I should see the policy "Milk for kids" in my list of draft policies

Scenario: Editing an existing draft policy
Given I have written a policy called "Legalise beards"
And I visit the list of draft policies
When I change the policy "Legalise beards" to "Decriminalise beards"
Then I should see the policy "Decriminalise beards" in my list of draft policies
