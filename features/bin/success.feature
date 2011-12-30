Feature: Bin - Success
  Scenario: Run a successful test with long format definition
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit --seed 1234 -j spec/jasmine/success/success.yml --format File --out spec/report.txt`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 1 total, 0 failures, no console usage
      And the report file "spec/report.txt" should have seed 1234

  Scenario: Run a successful test with legacy file reporting
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml --report spec/report.txt`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 1 total, 0 failures, no console usage

  Scenario: Run a successful test with shortened format definition
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml -f File:spec/report.txt`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 1 total, 0 failures, no console usage

