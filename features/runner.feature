Feature: Using the Runner directly
  Scenario: Succeed
    Given I have the following runner options:
      """
      :jasmine_config: spec/jasmine/success/success.yml
      :reporters:
      - [ 'File', 'spec/report.txt' ]
      """
    When I get a runner
      And I run the runner
    Then the runner should have an exit status of 0
    And the report file "spec/report.txt" should have 1 total, 0 failures, no console usage

  Scenario: JavaScript Error
    Given I have the following runner options:
      """
      :jasmine_config: spec/jasmine/success_with_error/success_with_error.yml
      """
    When I get a runner
      And I run the runner
    Then the runner should have an exit status of 1

  Scenario: Failure
    Given I have the following runner options:
      """
      :jasmine_config: spec/jasmine/failure/failure.yml
      :reporters:
      - [ 'File', 'spec/report.txt' ]
      """
    When I get a runner
      And I run the runner
    Then the runner should have an exit status of 1
    And the report file "spec/report.txt" should have 1 total, 1 failure, no console usage

