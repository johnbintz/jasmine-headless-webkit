Feature: Bin - Try to Click A Button
  Scenario: Don't leave page when clicking a button
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/click_button/click_button.yml -f File:spec/report.txt`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 0 total, 0 failures, no console usage

