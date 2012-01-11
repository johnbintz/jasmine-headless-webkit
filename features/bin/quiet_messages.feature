Feature: Bin - Quiet Messages
  Scenario: Run a test that would cause a lot of messages to be displayed and silence them all
    Given I have a test suite
    When I run `bin/jasmine-headless-webkit -q -j spec/jasmine/noisy/noisy.yml`
    Then the exit status should be 0
      And the output should not include "[Skipping File]"
      And the output should not include "You should mock"

