Feature: Bin - Runner Out
  Scenario: Write out the runner to a specified file
    Given I have a test suite
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml --runner-out spec/runner.html`
    Then the exit status should be 0
      And the file "spec/runner.html" should contain a JHW runner
    When I delete the file "spec/runner.html"

