Feature: Two files from source files
  Scenario: Files are ordered directly
    Given I have a test suite
    When I run `bin/jasmine-headless-webkit -j spec/jasmine/two_files_from_src_files/jasmine.yml -l`
    Then the exit status should be 0
      And the following files should be loaded in order:
        | vendor/vendor-file.js |
        | vendor/vendor.js |
        | app/app-file.js |
        | app/app.js |

