Feature: Bin - With Server
  Scenario: Run using an HTTP server
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit --use-server -j spec/jasmine/success/success.yml -f File:spec/report.txt`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 1 total, 0 failures, no console usage

