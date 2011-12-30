Feature: Bin - Failure
  Scenario: Run a failing test
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/failure/failure.yml -f File:spec/report.txt`
    Then the exit status should be 1
      And the report file "spec/report.txt" should have 1 total, 1 failure, no console usage

