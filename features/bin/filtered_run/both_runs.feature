Feature: Bin - Filtered Run - Both Runs
  Background:
    Given there is no existing "spec/report.txt" file

  Scenario: Run one and fail
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/filtered_failure/filtered_failure.yml -f File:spec/report.txt ./spec/jasmine/filtered_failure/failure_spec.js`
    Then the exit status should be 1
      And the report file "spec/report.txt" should have 1 total, 1 failure, no console usage

  Scenario: Run both and succeed
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/filtered_success/filtered_success.yml -f File:spec/report.txt ./spec/jasmine/filtered_success/success_one_spec.js`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 2 total, 0 failures, no console usage

  Scenario: Run both with console.log
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/filtered_success_with_console/filtered_success.yml -f File:spec/report.txt ./spec/jasmine/filtered_success_with_console/success_one_spec.js`
    Then the exit status should be 2
      And the report file "spec/report.txt" should have 2 total, 0 failures, yes console usage
