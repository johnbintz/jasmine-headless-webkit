---
title: jasmine-headless-webkit -- The fastest way to run your Jasmine specs!
---

# `jasmine-headless-webkit`
## Run your Jasmine specs at sonic boom speed!

[Jasmine](http://pivotal.github.com/jasmine/) is great. I love it. But running Jasmine when you need to test code that will run
in a browser environment can be problematic and slow:

* The Jasmine gem's server makes getting up and testing very fast, but F5-ing your browser for each test run is distracting.
* Jasmine CI uses Selenium, which speeds up the process a bit, but you're still rendering pixels in a browser, so it's slower than it should be.
* Node.js, EnvJS, and Rhino solutions for running Jasmine are great for anything that will never run in a real browser, since browser simulators are not true browsers.

But there's a solution for browser-based testing, and it dovetails perfectly into the Jasmine gem's already established protocols.

## Enter `jasmine-headless-webkit`

`jasmine-headless-webkit` uses the Qt WebKit widget to run your specs without needing to render a pixel. It's nearly
as fast as running in a JavaScript engine like Node.js, and since it's a real browser environment, all the modules
you would normally use, like jQuery and Backbone, work without any modifications. If you write your tests correctly,
they'll even work when running in the Jasmine gem's server with no changes to your code.

`jasmine-headless-webkit` also streamlines your workflow in other ways:

* It integrates with [Autotest](https://github.com/seattlerb/zentest) and can easily be used with [watchr](https://github.com/mynyml/watchr) to automate the running of your tests during development.
* It compiles [CoffeeScript](http://jashkenas.github.com/coffee-script/), both for your tests and for your application logic.
* It can be configured like RSpec, and its output is very similar to RSpec's output, so you don't need to learn too much new stuff to use and integrate it.

## How to use it

You can use it standalone:

    gem install jasmine-headless-webkit

Or you can use it with Bundler:

    gem 'jasmine-headless-webkit'

However you install it, you'll get a `jasmine-headless-webkit` executable. You'll also need to set up your project
to use the Jasmine gem:

    gem install jasmine
    jasmine init

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
  - **/*[Ss]pec.{js,coffee}
src_dir:
spec_dir: spec/javascripts
{% endhighlight %}

### *.coffee in my jasmine.yml file?!

Yes, `jasmine-headless-webkit` will support *.coffee files in `jasmine.yml`, while the normal Jasmine server currently
does not support out of the box. Once there's official support, you'll be able to easily switch between `jasmine-headless-webkit`
and the Jasmine test server when you're using CoffeeScript.

## Running the runner

    jasmine-headless-webkit [ -c / --colors ] 
                            [ --no-colors ] 
                            [ --keep ] 
                            [ -j / --jasmine-config <path to jasmine.yml> ]
                            <spec files to run>

### Coloring the output

`jasmine-headless-webkit` will not color output by default. This makes it easier to integrate with CI servers. If you want
colored output, use the `-c` flag.

