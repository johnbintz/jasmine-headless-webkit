Feature: Bin - Help
  Scenario: Display the Help
    Given I have a test suite
    When I run `bin/jasmine-headless-webkit -h`
    Then I should get help output
      And the exit status should be 0

