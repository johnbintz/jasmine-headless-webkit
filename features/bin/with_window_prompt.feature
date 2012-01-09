Feature: Bin - With window.prompt()
  Scenario: Alert the user that window.prompt() needs to be stubbed
    Given I have a test suite
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/window_prompt/window_prompt.yml`
    Then the exit status should be 0
      And the output should include "You should mock window.prompt"

