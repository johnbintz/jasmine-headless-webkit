---
title: jasmine-headless-webkit -- The fastest way to run your Jasmine specs!
layout: default
---

# Jasmine Headless WebKit
## Run your Jasmine specs at sonic boom speed!

<img src="images/f5.png" alt="Colored Output" />
[Jasmine](http://pivotal.github.com/jasmine/) is great. I love it. But running Jasmine when you need to test code that will run
in a browser environment can be problematic and slow:

* The [Jasmine gem](https://github.com/pivotal/jasmine-gem)'s server makes getting up and testing very fast, but F5-ing your browser for each test run is distracting.
* Jasmine CI uses Selenium, which speeds up the process a bit, but you're still rendering pixels in a browser, albeit with the option of rendering those pixels in a lot of different browsers at once.
* Node.js, EnvJS, and Rhino solutions for running Jasmine are great for anything that will never run in a real browser. I'm a big believer of running code destined for a browser in a browser itself, not a simulator.

But there's a solution for fast, accurate browser-based testing, using one of the most popular browser cores, and it dovetails perfectly into the Jasmine gem's already established protocols.

## Enter `jasmine-headless-webkit`

`jasmine-headless-webkit` uses the [Qt WebKit widget](http://trac.webkit.org/wiki/QtWebKit) to run your specs without needing to render a pixel. It's nearly
as fast as running in a JavaScript engine like Node.js, and, since it's a real browser environment, all the modules
you would normally use, like jQuery and Backbone, work without any modifications. If you write your tests correctly,
they'll even work when running in the Jasmine gem's server with no changes to your code.

`jasmine-headless-webkit` also streamlines your workflow in other ways:

* It integrates with [Autotest](https://github.com/seattlerb/zentest) and can easily be used with [watchr](https://github.com/mynyml/watchr) to automate the running of your tests during development.
* It compiles [CoffeeScript](http://jashkenas.github.com/coffee-script/), both for your tests and for your application logic.
* It can be configured like RSpec, and its output is very similar to RSpec's output, so you don't need to learn too much new stuff to use and integrate it.

## How do I use this wonderful toy?

You can use it standalone:

    gem install jasmine-headless-webkit

Or you can use it with Bundler:

    gem 'jasmine-headless-webkit'

However you install it, you'll get a `jasmine-headless-webkit` executable. You'll also need to set up your project
to use the Jasmine gem:

    gem install jasmine
    jasmine init

### What do I need to get it working?

Installation requires Qt 4.7.  The Internets will tell you how to get that for your particular environment.
`jasmine-headless-webkit` has been tested in the following environments:

* Mac OS X 10.6, with MacPorts Qt and Nokia Qt.mpkg
* Kubuntu 10.10

If it works in yours, [leave me a message on GitHub](https://github.com/johnbintz) or 
[fork this site](https://github.com/johnbintz/jasmine-headless-webkit/tree/gh-pages) and add your setup.

### How does it work?

`jasmine-headless-webkit` generates a static HTML file that includes the Jasmine JavaScript library from the Jasmine
gem, your application and spec files, and any helpers you may need. The runner then creates a WebKit widget that
loads the HTML file, runs the tests, and grabs the results of the test to show back to you. Awesome!

`jasmine-headless-webkit` uses the same `jasmine.yml` file that the Jasmine gem file uses to define where particular
files for the testing process are located:

{% highlight yaml %}
src_files:
  - public/assets/common.js
  - public/assets/templates.js
  - public/javascripts/models/**/*.js
  - public/javascripts/collections/**/*.js
  - public/javascripts/views/**/*.js
  - public/javascripts/models/**/*.coffee
  - public/javascripts/collections/**/*.coffee
  - public/javascripts/views/**/*.coffee
helpers:
  - helpers/**/*.{js,coffee}
spec_files:
  - "**/*[Ss]pec.{js,coffee}"
src_dir:
spec_dir: spec/javascripts
{% endhighlight %}

It also brings in the same copy of the Jasmine library that the Jasmine gem includes, so if you're testing in both environments,
you're guaranteed to get the same results in your tests.

#### `*.coffee` in my `jasmine.yml` file?!

Yes, `jasmine-headless-webkit` will support `*.coffee` files in `jasmine.yml`, which the normal Jasmine server currently
does not support out of the box. Once there's official support, you'll be able to easily switch between `jasmine-headless-webkit`
and the Jasmine test server when you're using CoffeeScript. CoffeeScript files are compiled and injected into the generated HTML
files.

#### Server interaction

Since there's no Jasmine server running, there's no way to grab test files from the filesystem via Ajax.
If you need to test server interaction, do one of the following:

* Stub your server responses using [Sinon.JS](http://sinonjs.org/).
* Use [PhantomJS](http://www.phantomjs.org/) against a running copy of a Jasmine server, instead of this project.

#### What else works?

`alert()` and `confirm()` work, though the latter always returns `true`. You should be mocking calls to `confirm()`,
of course:

{% highlight js %}
spyOn(window, 'confirm').andReturn(false)
{% endhighlight %}

`console.log()` also works, though it's just a wrapper around `JSON.stringify()`. This means that cyclical objects, like HTML
elements, can't be directly serialized (yet). Use jQuery to help you retrieve the HTML:

{% highlight js %}
console.log($('#element').parent().html())
{% endhighlight %}

## Running the runner

{% highlight bash %}
jasmine-headless-webkit [ -c / --colors ] 
                        [ --no-colors ] 
                        [ --keep ] 
                        [ -j / --jasmine-config <path to jasmine.yml> ]
                        <spec files to run>
{% endhighlight %}

The runner will return one of three exit codes:

* __0__ means your tests passed sucessfully.
* __1__ means you had a failure in your tests.
* __2__ means your tests passed, but you used `console.log()` somewhere.

### Setting default options

Much like RSpec, you can define the default options for each run of the runner. Place your global options into a
`~/.jasmine-headless-webkit` file and your per-project settings in a `.jasmine-headless-webkit` file at the root of
the project.

### Coloring the output

`jasmine-headless-webkit` will not color output by default. This makes it easier to integrate with CI servers. If you want
colored output, use the `-c` flag. With colored output, your tests will look like this:

<img class="large" src="images/colored-output.png" alt="Colored Output" />

If you have colors turned on globally, you can turn them off per-project or per-run with `--no-colors`.

### Preserving compiled output on errors

CoffeeScript logic errors can be hard to track down. Keep the generated HTML files with the `--keep` flag and you'll
get `specrunner.$$.html` files in your working directory.

### Using a different `jasmine.yml` file

If for some reason you're not using the default path for a `jasmine.yml` file (which is `spec/javascripts/support/jasmine.yml`),
you can provide that path with `-j`.

### Running only certain spec files

By default, if no files are passed into `jasmine-headless-webkit`, all possible spec files in the `spec_files` definition
will be run. You can limit the run to only certain files by passing those to `jasmine-headless-webkit`:

{% highlight bash %}
jasmine-headless-webkit spec/javascripts/models/node_viewer.coffee
{% endhighlight %}

## Automated testing during development

`jasmine-headless-webkit` works best when it's running all the time, re-running tests when you update the appropriate files.
Support for Autotest is built-in. All you need to do is create a `.jasmine-headless-webkit` file in your project directory
and Autotest will pick up that you want to use it for Jasmine. _(this only works by itself or with RSpec at the moment)_

You can also use it with watchr, which is what I do now. Here's the watchr script I use to run both RSpec and
`jasmine-headless-webkit`:

<script src="https://gist.github.com/965115.js?file=test.watchr.rb"></script>

## Rake tasks

You can create a Rake task for your headless Jasmine specs:

{% highlight ruby %}
require 'jasmine/headless/task'

Jasmine::Headless::Task.new('jasmine:headless') do |t|
  t.colors = true
  t.keep_on_error = true
  t.jasmine_config = 'this/is/the/path.yml'
end
{% endhighlight %}

## I have a problem or helpful suggestion, good sir.

Here's what you can do:

* Leave a ticket on [the Issues tracker](https://github.com/johnbintz/jasmine-headless-webkit/issues).
* [Fork'n'fix the code](https://github.com/johnbintz/jasmine-headless-webkit). Feel free to add a bunch of tests, too. I cowboyed this project when starting it, and I'm slowly getting back to being a good boy.
* Ping me on [Twitter](http://twitter.com/johnbintz) or on [GitHub](https://github.com/johnbintz).

## Credits & License

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

