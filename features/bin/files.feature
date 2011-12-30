Feature: Bin - Files
  Scenario: List the files a test suite will use
    Given I have a test suite
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml -l`
    Then the exit status should be 0
      And the output should include "spec/jasmine/success/success.js"
      And the output should include "spec/jasmine/success/success_spec.js"
