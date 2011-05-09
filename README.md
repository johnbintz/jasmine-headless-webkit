# Jasmine Headless WebKit runner

Run your specs at sonic boom speed! No pesky reload button or page rendering slowdowns!

## Introduction

This gem works with projects that have used the [Jasmine gem](https://github.com/pivotal/jasmine-gem) to
create a `jasmine.yml` file that defines what to test. The runner loads that
`jasmine.yml` file and executes the tests defined within in a Qt WebKit widget, displaying the results
to the console and setting the exit code to one of the following:

* 0 for success
* 1 for spec run failure
* 2 for spec run success, but `console.log` was called during the run

`console.log` works, too, so you can run your specs side-by-side in a browser if you're so inclined. It
serializes whatever you're passing in as as JSON string, so objects that are cyclical in nature will not
serialize. If anyone has a good solution for this, please suggest and/or fork'n'fix.

## Installation

`gem install jasmine-headless-webkit` or use Bundler.

Installation requires Qt 4.7. See [senchalabs/examples](https://github.com/senchalabs/examples) and [my fork
of examples](https://github.com/johnbintz/examples) for more information on the QtWebKit runner.

Tested in the following environments:

* Mac OS X 10.6, with MacPorts Qt and Nokia Qt.mpkg
* Kubuntu 10.10

Let me know via a message or in the Issues section if it works on your setup and it's not listed!

## Usage

    jasmine-headless-webkit [options] [path to jasmine.yml, defaults to spec/javascripts/support/jasmine.yml]

Current supported options:

* `-c`/`--colors` enables color output
* `--no-colors` disables color output

These options can also be placed into a `.jasmine-headless-webkit` file in your project root.

### CoffeeScript Support

`jasmine-headless-webkit` brings in the `coffee-script` gem and compiles & injects all CoffeeScript into the
generated HTML page. All you need to do is configure your `jasmine.yml` file to look for .coffee files:

    src_files:
      - app/assets/javascripts/**/*.coffee
    spec_files:
      - **/*[sS]pec.coffee

*(This will probably make it difficult to test your code in an official Jasmine server for now. You can try 
[a technique like this](https://github.com/jbaudanza/rack-asset-compiler/blob/master/examples/jasmine_config.rb) for compiling CoffeeScript when it's requested from the server
or use [this fork of jasmine-gem](https://github.com/johnbintz/jasmine-gem/tree/coffeescript-inline-support) which
is thoroughly untested.)*

You will get line numbers on compile errors, but not logic errors. This is a CoffeeScript thing, and they're working on it. :)

### JavaScript Dialogs

You can call `alert()` and `confirm()` in your code. `alert()` will print the message to the console, and
`confirm()` will always return true. There's no way right now to respond to `confirm()`, so it's best to
mock that call:

    spyOn(window, 'confirm').andReturn(false);

### Autotest Integration

`jasmine-headless-webkit` can integrate with Autotest. Your `jasmine.yml` file needs to be in the default
path, and you have to be ready to use a very alpha implementation of the feature. If used with RSpec 2,
Jasmine tests run after RSpec tests.

You need to create a `.jasmine-headless-webkit` file in your project root for this integration
to work.

`jasmine-headless-webkit` provides two new hooks: `:run_jasmine` and `:ran_jasmine` for before and after the
Jasmine specs have run. This is a good place to do things like re-package all your assets using 
[Jammit](http://documentcloud.github.com/jammit/):

    Autotest.add_hook(:run_jasmine) do |at|
      system %{jammit}
    end

### Server Interaction

`jasmine-headless-webkit` works the same as if you create an HTML file, manually load the Jasmine library and
your code & tests into the page, and open that page in a browser. Because of this, there's no way to handle
server interaction with your application or with a Jasmine server. If you need to test server interaction,
do one of the following:

* Stub your server responses using [Sinon.JS](http://sinonjs.org/)
* Use [PhantomJS](http://www.phantomjs.org/) against a running copy of a Jasmine server, instead of this project

## License

* Copyright (c) 2011 John Bintz
* Original Qt WebKit runner Copyright (c) 2010 Sencha Inc.
* Jasmine JavaScript library Copyright (c) 2008-2011 Pivotal Labs

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

