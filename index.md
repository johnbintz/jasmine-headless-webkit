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
* [Evergreen](https://github.com/jnicklas/evergreen) makes Jasmine testing in a Rails app as easy as pie, but not everyone writes for Rails.

But there's a solution for fast, accurate browser-based testing. with a focus on continuous testing,
using one of the most popular browser cores, and that dovetails perfectly into the Jasmine gem's already established protocols.

## Enter `jasmine-headless-webkit`

`jasmine-headless-webkit` uses the [QtWebKit widget](http://trac.webkit.org/wiki/QtWebKit) to run your specs without needing to render a pixel. It's nearly
as fast as running in a JavaScript engine like Node.js, and, since it's a real browser environment, all the modules
you would normally use, like jQuery and Backbone.js, work without any modifications. If you write your tests correctly,
they'll even work when running in the Jasmine gem's server with no changes to your code.

`jasmine-headless-webkit` also streamlines your workflow in other ways:

* It integrates with [Guard](https://github.com/guard/guard) for a continuous testing setup when using [`guard-jasmine-headless-webkit`](https://github.com/guard/guard-jasmine-headless-webkit).
* It integrates with [Sprockets](https://github.com/sstephenson/sprockets) to handle code requires & preprocessing and JavaScript templates.
* It compiles [CoffeeScript](http://jashkenas.github.com/coffee-script/), both for your tests and for your application logic.
* It can be configured like RSpec, and its output is very similar to RSpec's output, so you don't need to learn too much new stuff to use and integrate it.
* It provides cleaner debugging and backtrace output than a lot of other console-based test tools provide.
* It's *fast*.

## Is this for me?

That depends on what you need:

* If you're new to JavaScript testing, drop in [Pivotal's Jasmine gem](https://github.com/pivotal/jasmine-gem) and point your browser at http://localhost:8888/.
* If you're used to how the Jasmine gem works and want to move to a faster solution geared toward continuous testing, you're in the right place!
* If you want an even simpler config and access to all of your Rails routes and resources for a quasi-intergration testing setup, use [Evergreen](https://github.com/jnicklas/evergreen).
  You even get your choice of browser drivers for free (as opposed to just Selenium or WebKit) as well as headless testing!
* If you want true integration testing, where you test the whole application stack, use Cucumber and/or Capybara.
* If you're not using Rails and still want to unit test, the Jasmine gem or `jasmine-headless-webkit` is what you want.

'round here, we focus on unit testing and mocking external interfaces. No using your app's views or routes, no hitting the app server to
get resources, just mocking and stubbing the JavaScript code all by itself.

## How do I use this wonderful toy?

You can use it standalone:

    gem install jasmine-headless-webkit

Or you can use it with Bundler:

    gem 'jasmine-headless-webkit'

However you install it, you'll get a `jasmine-headless-webkit` executable. You'll also need to set up your project
to use the Jasmine gem:

    gem install jasmine
    jasmine init

Once you're good enough, you can make the `spec/javascripts/support/jasmine.yml` file yourself and skip the Pivotal Jasmine gem entirely.
It's what the cool kids do.

### What do I need to get it working?

Installation requires Qt 4.7. `jasmine-headless-webkit` has been tested in the following environments:

* Mac OS X 10.6 and 10.7, with MacPorts Qt, Homebrew Qt and Nokia Qt.mpkg
* Kubuntu 110.04, 10.10 and 10.04
* Ubuntu 11.04 and 9.10
* Arch Linux

If it works in yours, [leave me a message on GitHub](https://github.com/johnbintz) or
[fork this site](https://github.com/johnbintz/jasmine-headless-webkit/tree/gh-pages) and add your setup.

## Qt 4.7.X

The gem is compiled using `qt4-qmake` and you will need Qt 4.7.x or greater.
The version you have installed should be detected correctly, and the appropriate message for installing Qt should
be given if it's wrong. If it's not, please file a new issue!

### Manually checking the Qt version

Test that `qt4-qmake` it is installed and verify your version.
     qmake --version

If you have the Qt 4.7.x or greater, you are ready to install jasmine-headless-webkit.
     QMake version 2.01a
     Using Qt version 4.7.2 in /usr/lib

If you receive a different message, you can install `qt4-qmake` using one of the following commands as root:

### Ubuntu 11.04

{% highlight bash %}
sudo apt-get install libqt4-dev
sudo apt-get install qt4-qmake
sudo update-alternatives --config qmake # and select Qt 4's qmake
{% endhighlight %}

### Ubuntu 9.10

Running `sudo apt-get install libqt4-dev` and `sudo apt-get install qt4-qmake` will install qt4,
but it installs **version 4.5.2**, which will not be able to compile 
**jasmine-headless-webkit**, as it requires Qt 4.7.X or greater.

You will need to compile qt4-qmake from source
[Qt version 4.7.0](http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-4.7.0.tar.gz).
There are excellent [directions](http://doc.qt.nokia.com/latest/install-x11.html) on how to compile
the source code. You will need to ensure Qt is exported to your `$PATH` before using qmake, as the source code will
install to `/usr/local/Trolltech/`.

### Mac OS X 10.6 & 10.7

#### MacPorts

{% highlight bash %}
sudo port install qt4-mac
{% endhighlight %}

#### Homebrew

{% highlight bash %}
brew install qt
{% endhighlight %}

__(you may need to use `--build-from-source` on Lion)__

### My OS isn't on here!
[`capybara-webkit`](https://github.com/thoughtbot/capybara-webkit) has the best instructions for installing Qt on various other
systems that may not be covered here.

### How does it work?

`jasmine-headless-webkit` generates a static HTML file that includes the Jasmine JavaScript library from the Jasmine
gem, your application and spec files, and any helpers you may need. The runner then creates a WebKit widget that
loads the HTML file, runs the tests, and grabs the results of the test to show back to you. Awesome!

`jasmine-headless-webkit` uses the same `jasmine.yml` file that the Jasmine gem uses to define where particular
files for the testing process are located:

{% highlight yaml %}
src_files:
  - "**/*"
helpers:
  - helpers/**/*
spec_files:
  - "**/*_spec.*"
src_dir: app/assets/javascripts
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

#### Sprockets support

Nearly all of Sprockets is accessible to your test suite when using `jasmine-headless-webkit`.
It's easier to list the parts that aren't accessible:

* `*.erb` files are not processed at all (and are actually ignored) because it's assumed the contents of those files depend on an
  outside source, like a Rails app. That integration puts testing those files squarely in the "integration testing" realm, so
  it's not valid to support them in a unit testing tool.
* No CSS compilation happens, so no Sass or LESS.

If any gems have `vendor/assets/javascripts` in their list of files, such as `jquery-rails`, those are put in the asset
path along with the paths you define in `src_dir`:

{% highlight yaml %}
src_dir:
- app/assets/javascripts
- vendor/assets/javascripts
{% endhighlight %}

_Technically, `spec_dir` is in your asset path, too, but Jasmine's typical behavior of including `helpers` before `spec_dir` should
give you all the include power you need for defining specs._

If you want to keep `src_dir` as a string for backwards compatibility, you can add additional asset paths with, you guessed it, `asset_paths`:

{% highlight yaml %}
src_dir: app/assets/javascripts

asset_paths:
- vendor/assets/javascripts
{% endhighlight %}

`asset_paths` are added to the Sprockets asset paths after `src_dir`.

In order for Sprockets support to work as intended, you should define your `src_files` and `spec_files` as such:

{% highlight yaml %}
src_files:
  - "**/*.*"
spec_files:
  - "**/*[Ss]pec.*"
{% endhighlight %}

This will include everything that Sprockets understands in all your `src_dir` and `spec_dir` paths. At that point, use Sprockets `require`
statements to define the include order of your files. Using the `--list` option on the command line to list the load order of files, combined
with the `--runner-out` option to write HTML runner files to a place where the browser can easily get to them, is very helpful when moving to
a Sprockets-managed project.

JavaScript Templates are supported too, including [haml-sprockets](https://github.com/dharanasoft/haml-sprockets). Use them as you would any other
JavaScript file, and ensure the load order is right, and the necessary code in the JST namespace will be created.

Since any gem with `vendor/assets/javascripts` is usable, that means Jasmine-specific gems are possible now. [jasmine-spec-extras](https://github.com/johnbintz/jasmine-spec-extras)
is the first such gem, which provides `jasmine-jquery`, `sinon`, and any other useful Jasmine helpers, vendored into the gem so you can easily include
them into your project without having to manually manage them yourself:

{% highlight coffeescript %}
#= require sinon
#= require backbone

describe "Spy thing", ->
  it 'should fire a callback', ->
    collection = new Backbone.Collection()
    spy = sinon.spy()
    collection.bind('reset', spy)
    collection.reset()
{% endhighlight %}

If you have to use ERB to inject information into the JavaScript or CoffeeScript files in your project, I recommend that you move those
injections to a file that is included separately from the code, or include them in `application.*.erb` like this:

{% highlight coffeescript %}
# File: app/assets/javascripts/application.coffee.erb

#= require 'jquery'
#= require 'my_library'

MyLibrary.root_url = <%= api_root_path %>
{% endhighlight %}

Sprockets support is still pretty new, so as myself and others discover the best way to set up code that can be used in both places, those
practices will be outlined here.

#### Caching, caching, caching

`jasmine-headless-webkit` does two things that are CPU intensive (besides running tests): compiling CoffeeScript and analyzing
spec files to get line number information for nicer spec failure messages (_did I mention you get really nice spec failure
messages with `jasmine-headless-webkit`, too?_). These two operations are cached into the `.jhw-cache/` folder from where the
runner is executed. When this cache is combined with running tests continuously using Guard, runtime overhead is reduced to almost
nothing.

Of course, being a cache, it takes time to warm up. The first time you run `jasmine-headless-webkit` on a big project, it can take
several seconds to warm the cache. After that, enjoy an almost 20% speedup in runtime (tested on exactly one project's runtime,
YMMV).

#### What else works?

`alert()` and `confirm()` work, though the latter always returns `true`. You should be mocking calls to `confirm()`,
of course:

{% highlight js %}
spyOn(window, 'confirm').andReturn(false)
{% endhighlight %}

`console.log()` also works. It uses one of three methods for serializing what you've provided:

* If the object given responds to `toJSON`, `jasmine-headless-webkit` uses `JSON.stringify(object.toJSON())`.
* If the object is a jQuery object, it is serialized with `jQuery('<div>').append(object).html()` 
  and pretty-printed using the HTML beautifier from [JS Beautifier](https://github.com/einars/js-beautify).
* If none of these apply, it uses a hacked-up version of [jsDump](https://github.com/NV/jsDump) that ignores 
  Functions on objects and prevents cyclical references.

If you need a heavy-weight object printer, you also have `console.pp()`, which uses Jasmine's built-in pretty-printer if available, and falls back to `JSON.stringify()` if it's not.

You also get an additional method, `console.peek()`, which calls `console.log()` with the provided parameter, then passes the parameter back along so you
can continue to work with it. It's the equivalent of `.tap { |o| p o }` in Ruby.

## Running the runner

{% highlight bash %}
jasmine-headless-webkit [ -c / --colors ]
                        [ --no-colors ]
                        [ --no-full-run ]
                        [ --keep ]
                        [ -l / --list ]
                        [ --report <report file> ]
                        [ --runner-out <html file> ]
                        [ -j / --jasmine-config <path to jasmine.yml> ]
                        [ --seed <random seed> ]
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

### Listng what files `jasmine-headless-webkit` will include

If your tests are not picking up a file you thought they should be, or they're being included in the wrong order,
run with the `-l` flag to get a list of the files that `jasmine-headless-webkit` will include in the generated HTML file.
*Very* handy for making sure your Sprockets requires are working correctly.

### Coloring the output

`jasmine-headless-webkit` will not color output by default. This makes it easier to integrate with CI servers. If you want
colored output, use the `-c` flag. With colored output, your tests will look like this:

<img class="large" src="images/colored-output.png" alt="Colored Output" />

If you have colors turned on globally, you can turn them off per-project or per-run with `--no-colors`.

### Preserving compiled output on errors

CoffeeScript logic errors can be hard to track down. Keep the generated HTML files with the `--keep` flag and you'll
get `specrunner.$$.html` files in your working directory.

### Writing out a machine-readable report

Use the `--report` option to create a detailed report file:

    PASS||Statement||One||file.js:23
    FAIL||Statement||Two||file.js:23
    CONSOLE||Yes
    ERROR||Uh oh||file.js:23
    TOTAL||1||2||3||T

[`guard-jasmine-headless-webkit`](http://github.com/guard/guard-jasmine-headless-webkit/) uses this for the Growl notifications.
You can also use it in your own setups, to run specs remotely and stick the results into a CI system. You can use
`Jasmine::Headless::Report` to interpret the file and transform the output.

### Using a different `jasmine.yml` file

If for some reason you're not using the default path for a `jasmine.yml` file (which is `spec/javascripts/support/jasmine.yml`),
you can provide that path with `-j`.

### Randomizing the order of spec files

Spec files are shuffled into a random order before each run. This lets you find issues where spec files may depend on state
established in prior executed spec files -- a bad thing. After each run, you'll get the random seed used to randomize the files:

`Test ordering seed: --seed 1234`

If you're getting weird results related to the particular order of a run of specs, pass that same seed value back in
and get to work!

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

### Writing the HTML runner to another location

If you want to use the runner file in other places, use the `--runner-out` parameter with the name of the target file.
The HTML produced uses the Jasmine `HtmlReporter` if not loaded in `jasmine-headless-webkit`, so you should be able
to just open it in a browser and have it work.

If you always want the reporter written to a particular location, you can define that location in `jasmine.yml`:

{% highlight yaml %}
runner_output: "runner.html"
{% endhighlight %}

## Running the runner from a Ruby program

You can call the runner from Ruby:

{% highlight ruby %}
require 'jasmine-headless-webkit'

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

### guard-rails-assets

With Sprockets support now in `jasmine-headless-webkit`, there's less of a need for most users for `guard-rails-assets`, unless you really need to get
at those ERB files in your project. [`guard-rails-assets`](http://github.com/dnagir/guard-rails-assets) is what you want to use in this case.
It will watch your app's code for changes and rebuild your pipelined JS code, ready to be tested with `jasmine-headless-webkit`:

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

If you're still using Jammit it shove your JS templates into one file, you can use a Guard for that, too! [`guard-jammit`](http://github.com/guard/guard-jammit)
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

## Rake tasks

You can create a Rake task for your headless Jasmine specs:

{% highlight ruby %}
require 'jasmine-headless-webkit'

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

## Continuous integration & testing using Xvfb

Since most continuous integration servers do not have a display, you will need to use
Xvfb or virtual framebuffer Xserver for Version 11. If you elect not to use Xvfb, you will
need to have a browser and graphical display to run `jasmine-headless-webkit -c`.

Reference: [Xvfb Manpages](http://manpages.ubuntu.com/manpages/natty/man1/Xvfb.1.html)

### Install Xvfb
      sudo apt-get install xvfb

### Resolve missing dependencies
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

#### ...as a Rake task

     xvfb-run rake jasmine:headless 
     # ...or...
     xvfb-run jasmine-headless-webkit -c

Reference: [MARTIN DALE LYNESS](http://blog.martin-lyness.com/archives/installing-xvfb-on-ubuntu-9-10-karmic-koala)

#### ...seamlessly

First run Xvfb in the background:

    Xvfb :0 -screen 0 1024x768x24 > /dev/null 2>&1 &

Then, set your `DISPLAY` to point at the Xvfb instance. Putting all this in your `.bash_profile` or equivalent startup
script makes this a lot easier:

    xdpyinfo -display :0 &>/dev/null && export DISPLAY=:0

See [Paul Goscicki's post](http://paulgoscicki.com/archives/2011/09/run-guard-jasmine-headless-webkit-without-x-server/) for
more details on the setup. Thanks, Paul!

## RubyMine

RubyMine may throw an error when running rake spec, you will need to provide a
JavaScript runtime environment.

     rake aborted!
     Could not find a JavaScript runtime.
     See https://github.com/sstephenson/execjs
     for a list of available runtimes.

To resolve this problem, install and use the `therubyracer` gem, which is the embed V8 JavaScript interpreter into Ruby.
Additionally, you can set the `EXECJS_RUNTIME` environment variable to a [valid ExecJS runtime name](https://github.com/sstephenson/execjs/blob/master/lib/execjs/runtimes.rb#L55).

    export EXECJS_RUNTIME=Node

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

