Feature: Reporters
  In order to allow for multiple types of output
  I should be able to
  Manage reporters and decide which ones to use

  Scenario: Use default reporters
    Given I have the default runner options
    When I get a runner
      And I get a template writer
    Then the template should use the "Console" reporter to "stdout"
      And the command to run the runner should not include a report file

  Scenario: Use a file reporter
    Given I have the default runner options
      And I have the following reporters:
        | Name | File |
        | Console | |
        | File | file |
    When I get a runner
      And I get a template writer
    Then the template should use the "Console" reporter to "stdout"
      And the template should use the "File" reporter to "report:0"
      And the command to run the runner should include the report file "file"

