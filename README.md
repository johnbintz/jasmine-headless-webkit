# Jasmine Headless WebKit Runner

Run your specs at sonic boom speed! No pesky reload button or page rendering slowdowns! Jasmine
Headless WebKit Runner is a great way to run continuous integration without running a Web browser,
such as FireFox or Chrome.

## Install Jasmine Headless WebKit
The simplest way to install Jasmine Headless Webkit is to install it via the Gemfile.
Add `gem "jasmine-headless-webkit"` to your Gemfile, and run `bundle install`. This gem has three gem dependencies:

     coffee-script >= 2.2
     jasmine ~> 1.1.beta
     rainbow >= 0

Next, run `bundle install`

## Configure Jasmine

In the **jasmine.yml** file, located under the **support** sub-directory, you can control
which source files you would like to test. The default line that includes all JavaScript
files is `public/javascripts/**/*.js`, but this does not guarantee an order of execution.
It is recommended that you include files that jQuery plug-ins may depend on first.

     src_files:
       public/javascripts/jquery.min.js
       public/javascripts/underscore.js
       public/javascripts/underscore.date.min.js
       public/javascripts/jquery-ui-1.8.14.custom.min.js
       public/javascripts/**/*.js

## Continuous Integration

Since most continuous integration servers do not have a display, you will need to use
Xvfb or virtual framebuffer Xserver for Version 11 [Xvfb Manpages]
(http://manpages.ubuntu.com/manpages/natty/man1/Xvfb.1.html).

1.  `sudo apt-get install xvfb`
2.  run `Xvfb :99 -ac` and resolve missing dependencies.
     *        `sudo apt-get install x11-xkb-utils`
     *        `sudo apt-get install xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic`
     *        `sudo apt-get install xserver-xorg-core`
3. Use Xvfb to run the headless rake command `xvfb-run rake jasmine:headless` or `xvfb-run jasmine-headless-webkit -c`
4. Reference: [MARTIN DALE LYNESS](http://blog.martin-lyness.com/archives/installing-xvfb-on-ubuntu-9-10-karmic-koala)

# Gotcha(s)

## Qt 4.7.X

The gem is compiled using **qt4-qmake** and you will need Qt 4.7.x or greater.
To test if it is installed, you should run `qmake --version` and you should
receive something like:

     QMake version 2.01a
     Using Qt version 4.7.2 in /usr/lib

If you receive a different message, you can install qt4-qmake using the following commands as root:

**Ubuntu 11.04**

     sudo apt-get install libqt4-dev
     sudo apt-get install qt4-qmake

**Mac OS X 10.6**

     sudo port install qt4-mac

**Ubuntu 9.10**

Running `sudo apt-get install libqt4-dev` and `sudo apt-get install qt4-qmake` will install qt4,
but it installs **version 4.5.2**, which will not be able to install
`gem "jasmine-headless-webkit"`, as it requires Qt 4.7.X or later version.

You will need to compile qt4-qmake from source
[Qt version 4.7.0](http://get.qt.nokia.com/qt/source/qt-everywhere-opensource-src-4.7.0.tar.gz).
There are excellent [directions](http://doc.qt.nokia.com/latest/install-x11.html) on how to compile
the source code. You will need to ensure Qt is exported to your $PATH before using qmake, as it will
install to /usr/local/Trolltech/.

## RubyMine

RubyMine may throw an error when running rake spec, you will need to provide a
JavaScript runtime environment. Install `gem "therubyracer"` to resolve this problem.

     rake aborted!
     Could not find a JavaScript runtime.
     See https://github.com/sstephenson/execjs
     for a list of available runtimes.

http://johnbintz.github.com/jasmine-headless-webkit/ has the most up-to-date information on using
this project. You can see the source of that site on the gh-pages branch.

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

