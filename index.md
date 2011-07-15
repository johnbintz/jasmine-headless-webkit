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

`jasmine-headless-webkit` uses the [QtWebKit widget](http://trac.webkit.org/wiki/QtWebKit) to run your specs without needing to render a pixel. It's nearly
as fast as running in a JavaScript engine like Node.js, and, since it's a real browser environment, all the modules
you would normally use, like jQuery and Backbone, work without any modifications. If you write your tests correctly,
they'll even work when running in the Jasmine gem's server with no changes to your code.

`jasmine-headless-webkit` also streamlines your workflow in other ways:

* It integrates with [Guard](https://github.com/guard/guard) when using [`guard-jasmine-headless-webkit`](https://github.com/guard/guard-jasmine-headless-webkit).
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

Installation requires Qt 4.7.  [`capybara-webkit`](https://github.com/thoughtbot/capybara-webkit) has the best instructions for installing Qt on various
operating systems, so I'm not going to duplicate their work.
`jasmine-headless-webkit` has been tested in the following environments:

* Mac OS X 10.6, with MacPorts Qt and Nokia Qt.mpkg
* Kubuntu 10.10
* Arch Linux

If it works in yours, [leave me a message on GitHub](https://github.com/johnbintz) or 
[fork this site](https://github.com/johnbintz/jasmine-headless-webkit/tree/gh-pages) and add your setup.

### How does it work?

`jasmine-headless-webkit` generates a static HTML file that includes the Jasmine JavaScript library from the Jasmine
gem, your application and spec files, and any helpers you may need. The runner then creates a WebKit widget that
loads the HTML file, runs the tests, and grabs the results of the test to show back to you. Awesome!

`jasmine-headless-webkit` uses the same `jasmine.yml` file that the Jasmine gem uses to define where particular
files for the testing process are located:

{% highlight yaml %}
src_files:
  - public/assets/common.js
  - public/assets/templates.js
  - public/javascripts/models/**/*.js
  - public/javascripts/collections/**/*.js
  - public/javascripts/views/**/*.js
  - app/coffeescripts/models/**/*.coffee
  - app/coffeescripts/collections/**/*.coffee
  - app/coffeescripts/views/**/*.coffee
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

Never done Jasmine in CoffeeScript? It looks like this:

{% highlight coffeescript %}
describe 'Component', ->
  describe 'StorylineNode', ->
    model = null

    beforeEach ->
      model = new ComponentStorylineNode({id: 1})

    it 'should not be new', ->
      expect(model.isNew()).toEqual(false)
{% endhighlight %}

...and it turns into this...

{% highlight js %}
describe('Component', function() {
  return describe('StorylineNode', function() {
    var model;
    model = null;
    beforeEach(function() {
      return model = new ComponentStorylineNode({
        id: 1
      });
    });
    return it('should not be new', function() {
      return expect(model.isNew()).toEqual(false);
    });
  });
});
{% endhighlight %}

#### Server interaction

Since there's no Jasmine server running, there's no way to grab test files from the filesystem via Ajax.
If you need to test server interaction, do one of the following:

* Stub your server responses using [Sinon.JS](http://sinonjs.org/), the recommended way.
* Use [PhantomJS](http://www.phantomjs.org/) against a running copy of a Jasmine server, instead of this project.

#### What else works?

`alert()` and `confirm()` work, though the latter always returns `true`. You should be mocking calls to `confirm()`,
of course:

{% highlight js %}
spyOn(window, 'confirm').andReturn(false)
{% endhighlight %}

`console.log()` also works.  It uses `JSON.stringify()` to serialize objects. This means that cyclical objects, like HTML elements, can't be directly serialized (yet). Use jQuery to help you retrieve the HTML:

{% highlight js %}
console.log($('#element').parent().html())
{% endhighlight %}

If you need a heavy-weight object printer, you also have `console.pp()`, which uses Jasmine's built-in pretty-printer if available, and falls back to `JSON.stringify()` if it's not. This one's the best for
printing HTML nodes, but it can be pretty noisy when printing objects.

## Running the runner

{% highlight bash %}
jasmine-headless-webkit [ -c / --colors ] 
                        [ --no-colors ] 
                        [ --no-full-run ] 
                        [ --keep ] 
                        [ --report <report file> ] 
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

### Writing out a machine-readable report

Use the `--report` option to create a simple report file like this:

    <total tests>/<failures>/<T if console was used, F otherwise>/<total time>

[`guard-jasmine-headless-webkit`](http://github.com/guard/guard-jasmine-headless-webkit/) uses this for the Growl notifications.

### Using a different `jasmine.yml` file

If for some reason you're not using the default path for a `jasmine.yml` file (which is `spec/javascripts/support/jasmine.yml`),
you can provide that path with `-j`.

### Running only certain spec files

By default, if no files are passed into `jasmine-headless-webkit`, all possible spec files in the `spec_files` definition
will be run. You can limit the run to only certain files by passing those to `jasmine-headless-webkit`:

{% highlight bash %}
jasmine-headless-webkit spec/javascripts/models/node_viewer.coffee
{% endhighlight %}

#### Filtered runs and full runs

Typically, targeted spec running is done by a tool like Guard, and the order of running goes like this:

* Run the filtered spec
  * If it fails, stop processing and alert the user
  * If it succeeds, run all specs and alert on success or failure

Having your test running tool re-run `jasmine-headless-webkit` is fast, but there's still the cost of instantiating QtWebKit and Ruby
with each run. Versions of `jasmine-headless-webkit` 0.3.0 and greater will do this for you, keeping the widget in memory and running
Jasmine tests on first the filtered suite, and then the complete suite. The results you'll get are for the last run that's executed, which
is typically what you want to know anyway. Newer versions of `guard-jasmine-headless-webkit` also support this behavior. This trims
valuable seconds off of testing with every run, saving you enough time every day to run to the coffee shop and get some delicious brew!

If you don't want this behavior, pass in `--no-full-run` and filtered runs will be the only thing that runs when you request one.

## Running the runner from a Ruby program

You can call the runner from Ruby:

{% highlight ruby %}
require 'jasmine/headless/runner'

status_code = Jasmine::Headless::Runner.run(
  :colors => false, 
    #=> true to get colors
  :remove_html_file => true, 
    #=> false to keep specrunners on failure
  :jasmine_config => 'spec/javascripts/support/jasmine.yml',
    #=> run a different config
  :report => false, 
    #=> filename if a report file should be written
  :full_run => true, 
    #=> false to not run a full run after a targeted run
  :files => ['file_one_spec.js', 'file_two_spec.coffee']
    #=> files to use for a targeted run, [] to run all
)
{% endhighlight %}

## Automated testing during development

`jasmine-headless-webkit` works best when it's running all the time, re-running tests when you update the appropriate files.
If you use [Guard](https://github.com/guard/guard/), install [`guard-jasmine-headless-webkit`](http://github.com/guard/guard-jasmine-headless-webkit/)
and run `guard init jasmine-headless-webkit` to add the necessary bits to your `Guardfile` to test a Rails 3.1 (or a well-structured Rails 3.0) app.

### Rails 3.1 and the Asset Pipeline

Since your JS code can now flow through the Rails 3.1 asset pipeline, and since it's not easy for non-Rails apps to get access to that pipeline,
testing your pipelined code in Rails 3.1 is a bit more difficult. The best way is to regenrate your code with each change and then run
`jasmine-headless-webkit` on the code, and now, there's a Guard for that! [`guard-rails-assets`](http://github.com/dnagir/guard-rails-assets) will watch
your app's code for changes and rebuild your pipelined JS code, ready to be tested with `jasmine-headless-webkit`:

{% highlight ruby %}
guard 'rails-assets' do
  watch(%r{^app/assets/javascripts/(.*)\.(js|coffee)$})
end

guard 'jasmine-headless-webkit' do
  watch(%r{^public/assets/.*\.js$})
  watch(%r{^spec/javascripts/.*\.coffee$})
end
{% endhighlight %}

### Jammit for JS templates

If you like to use Jammit to shove together your JS templates into one file, you can use a Guard for that, too! [`guard-jammit`](http://github.com/guard/guard-jammit)
provides Jammit watching support, but the current version (as of 2011-06-18) does not support some changes to Jammit's internals. Use [my fork](http://github.com/johnbintz/guard-jammit)
until that gets fixed.

{% highlight ruby %}
guard 'jammit' do
  watch(%r{^app/views/.*\.jst$$})
end

guard 'jasmine-headless-webkit' do
  watch(%r{^public/assets/.*\.js$})
  watch(%r{^spec/javascripts/.*\.coffee$})
end
{% endhighlight %}

### Autotest

Support for Autotest is *deprecated* and no new features will be added to the Autotest runners unless provided by other users.

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

If you've bundled `jasmine-headless-webkit` in with Rails, you'll also get a basic task for running your
Jasmine specs. Be sure to include the gem in the development group so you get with a normal call to `rake -T`:

{% highlight ruby %}
group :test, :development do
  gem 'jasmine-headless-webkit'
end
{% endhighlight %}

<pre>
# rake -T

rake jasmine:headless     # Run Jasmine specs headlessly
</pre>

This is the same as running `jasmine-headless-webkit -c`.

## Continuous Integration Using Xvfb

Since most continuous integration servers do not have a display, you will need to use
Xvfb or virtual framebuffer Xserver for Version 11. If you elect not to use Xvfb, you will
need to have a browser and graphical display to run `jasmine-headless-webkit -c`.

Reference: [Xvfb Manpages](http://manpages.ubuntu.com/manpages/natty/man1/Xvfb.1.html)

### Install Xvfb
      sudo apt-get install xvfb

### Resolve Missing Dependencies
To resolve missing dependencies, you will need to know what to install.
	$ Xvfb :99 -ac
You will see a long list of warning messages:

     [dix] Could not init font path element /usr/share/fonts/X11/misc,
     removing from list!
     [dix] Could not init font path element /usr/share/fonts/X11/cyrillic,
     removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/100dpi/:unscaled, removing from list!
     [dix] Could not init font path element
      /usr/share/fonts/X11/75dpi/:unscaled, removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/Type1, removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/100dpi, removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/75dpi, removing from list!
     sh: /usr/bin/xkbcomp: not found
     (EE) Error compiling keymap (server-42)
     (EE) XKB: Couldn't compile keymap
     [config/dbus] couldn't take over org.x.config:
     org.freedesktop.DBus.Error.AccessDenied 
     (Connection ":1.74" is not allowed to
     own the service "org.x.config.display99" 
     due to security policies in the configuration file)	

Installing the following packages would resolve the above warning messages. Your
missing packages may be different depending on the packages you have installed.
     sudo apt-get install x11-xkb-utils
     sudo apt-get install xfonts-100dpi xfonts-75dpi 
     sudo apt-get install xfonts-scalable xfonts-cyrillic
     sudo apt-get install xserver-xorg-core

Once you have resolved these dependencies, you should see:
     [dix] Could not init font path element /usr/share/fonts/X11/misc,
     removing from list!
     [dix] Could not init font path element /usr/share/fonts/X11/cyrillic,
     removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/100dpi/:unscaled, removing from list!
     [dix] Could not init font path element
      /usr/share/fonts/X11/75dpi/:unscaled, removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/Type1, removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/100dpi, removing from list!
     [dix] Could not init font path element 
     /usr/share/fonts/X11/75dpi, removing from list!

### Run with Xvfb
Use Xvfb to run the headless rake command. This will resolve the issue of jasmine-webkit-specrunner failing to connect
to X server.
     xvfb-run rake jasmine:headless 
     xvfb-run jasmine-headless-webkit -c

Reference: [MARTIN DALE LYNESS](http://blog.martin-lyness.com/archives/installing-xvfb-on-ubuntu-9-10-karmic-koala)

## Qt 4.7.X

The gem is compiled using **qt4-qmake** and you will need Qt 4.7.x or greater.
Test that qt4-qmake it is installed and verify your version.
     qmake --version

If you have the Qt 4.7.x or greater, you are ready to install jasmine-headless-webkit.
     QMake version 2.01a
     Using Qt version 4.7.2 in /usr/lib

If you receive a different message, you can install qt4-qmake using one of the following commands as root.

### Ubuntu 11.04

     sudo apt-get install libqt4-dev
     sudo apt-get install qt4-qmake

### Mac OS X 10.6

     sudo port install qt4-mac

### Ubuntu 9.10

Running `sudo apt-get install libqt4-dev` and `sudo apt-get install qt4-qmake` will install qt4,
but it installs **version 4.5.2**, which will not be able to compile 
**jasmine-headless-webkit**, as it requires Qt 4.7.X or greater.

You will need to compile qt4-qmake from source
[Qt version 4.7.0](http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-4.7.0.tar.gz).
There are excellent [directions](http://doc.qt.nokia.com/latest/install-x11.html) on how to compile
the source code. You will need to ensure Qt is exported to your $PATH before using qmake, as the source code will
install to /usr/local/Trolltech/.

## RubyMine

RubyMine may throw an error when running rake spec, you will need to provide a
JavaScript runtime environment.

     rake aborted!
     Could not find a JavaScript runtime.
     See https://github.com/sstephenson/execjs
     for a list of available runtimes.

To resolve this problem, install the **therubyracer** gem, which is the embed V8 JavaScript interpreter into Ruby.
Reference: [therubyracer](https://github.com/cowboyd/therubyracer)

You can use it standalone:

    gem install therubyracer

Or you can use it with Bundler:

    gem 'therubyracer'

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

