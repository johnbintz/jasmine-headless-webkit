Feature: Use console.log
  Scenario: Run a successful test that uses console.log
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/console_log/console_log.yml -f File:spec/report.txt`
    Then the exit status should be 2
      And the report file "spec/report.txt" should have 1 total, 0 failures, yes console usage

