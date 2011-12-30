Feature: Bin - Success with JS Error
  Scenario: Succeed
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/success_with_error/success_with_error.yml -f File:spec/report.txt`
    Then the exit status should be 1
