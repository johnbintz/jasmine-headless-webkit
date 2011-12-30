Feature: Bin - Try to Leave Page
  Scenario: Fail on trying to leave the page
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/leave_page/leave_page.yml -f File:spec/report.txt`
    Then the exit status should be 1
      And the report file "spec/report.txt" should exist

