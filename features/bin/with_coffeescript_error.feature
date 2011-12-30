Feature: Bin - With CoffeeScript error
  Scenario: Fail on CoffeeScript error
    Given there is no existing "spec/report.txt" file
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/coffeescript_error/coffeescript_error.yml -f File:spec/report.txt`
    Then the exit status should be 1
      And the report file "spec/report.txt" should not exist

