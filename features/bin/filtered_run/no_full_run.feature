Feature: Bin - No Full Run
  Background:
    Given there is no existing "spec/report.txt" file

  Scenario: Only run the filtered run
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/filtered_success/filtered_success.yml -f File:spec/report.txt --no-full-run ./spec/jasmine/filtered_success/success_one_spec.js`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 1 total, 0 failure, no console usage

  Scenario: Use a file outside of the normal test run
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/filtered_success/filtered_success.yml -f File:spec/report.txt ./spec/jasmine/filtered_success/success_other_file.js`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 1 total, 0 failure, no console usage

