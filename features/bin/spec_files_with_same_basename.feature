Feature: Bin - Two spec files with same basename
  Scenario: Run both files
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/two_spec_files_same_basename/jasmine.yml -f File:spec/report.txt`
    Then the exit status should be 0
      And the report file "spec/report.txt" should have 2 total, 0 failures, no console usage

