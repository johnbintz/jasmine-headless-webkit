## 0.7.2

* Improved finding of CoffeeScript spec line locations
* Improved Runner reporting of which expectations failed
* Initial vendored helper support, paving the way for Sprockets integratioon (maybe!)
* Add 1.9.3-rc1 test support and fixes
* Add console.peek()

## 0.7.1

* Bugfix for missing digest/sha1 import

## 0.7.0

* Major C++ cleanup, now much more modular
* Greatly improved object inspection and printing provided by jsDump and beautify-js

## 0.6.3

* Ensure Rubygems is available before doing version comparison
* Fix other build problems
* Better output for jQuery nodes

## 0.6.2

* Clean up C++ and test running

## 0.6.1

* Ensure YAML is loaded before use
* Make sure specs can't break out of the page they're running in
* Fix compilation on FreeBSD

## 0.6.0

* File and line number information for failing specs
* Try to build the runner if it's missing
* Kill warnings and streamline includes

## 0.5.0

* Run all tests after focused run if `console.log` was used
* Ensure Rake task works outside of Rails
* Ensure focused tests aren't run when CLI called with no files
* Support globs in focused test filters
* Raise exceptions on Rake task failures
* Update to use Jasmine 1.1

## 0.4.2

* Fix Rails 3.1 Railtie so it's included properly
* Fix compilation of runner on Linux
* Run files that are outside of the project's scope

## 0.4.1

* Fix CoffeeScript concatenation bug
* Report CoffeeScript errors better

## 0.4.0

* Change how tests are counted for totals
* Run targeted and full tests in the same runner instance for speed!
* Concatenate adjacent CoffeeScript files before compilation for more speed!
* Ensure files are not required twice
* Break out runner usage from CLI so that it can be resued in Rake tasks and elsewhere
* Add a Rails 3.1 task to precompile all assets with a specific "MD5 hash"

## 0.2.3

* Better messages for JavaScript errors
* `console.pp` added for more in-depth object inspection

## 0.2.2

* Write out a reporting file that can be used for Guard notification

## 0.2.1

* Avoid a Railtie so JHW works outside of Rails

## 0.2.0

* Add a Rake task and a default task for Rails
* Global runner configuration via ~/.jasmine-headless-webkit
* Custom Jasmine reporter for better user feedback
* Specify the specs to be run, instead of always running them all
* Move README to gh-pages site

