## Introduction

This gem works with projects that have use the [Jasmine gem](https://github.com/pivotal/jasmine-gem) to 
create a `jasmine.yml` file that defines what to test in their Jasmine project. The runner loads that
`jasmine.yml` file and executes the
tests in a Qt WebKit widget, displaying the results to the console and setting the exit code to 0 for
success or 1 for failure.

`console.log` works, too, so you can run your specs side-by-side in a browser if you're so inclined.

## Usage

`jasmine-headless-webkit` [path to jasmine.yml, defaults to spec/javascripts/support/jasmine.yml]

*This gem is currently as rough as it gets.*

Installation requires Qt 4.7. See [senchalabs/examples](https://github.com/senchalabs/examples) and [my fork
of examples](https://github.com/johnbintz/examples) for more information on the QtWebKit runner.

Copyright (c) 2010 Sencha Inc.
Copyright (c) 2011 John Bintz
Jasmine JavaScript library Copyright (c) 2008-2011 Pivotal Labs

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


