source :rubygems

# Specify your gem's dependencies in jasmine-headless-webkit.gemspec
gemspec

gem 'rspec'
gem 'fakefs', :require => nil
gem 'guard'

gem 'guard-rspec'
gem 'guard-shell'
gem 'guard-coffeescript'
gem 'guard-cucumber'

require 'rbconfig'
case RbConfig::CONFIG['host_os']
when /darwin/
when /linux/
  gem 'libnotify'
end

gem 'mocha'

gem 'cucumber'

gem 'jquery-rails', '~> 1.0.0'
gem 'ejs'

gem 'guard-jasmine-headless-webkit', :git => 'git://github.com/johnbintz/guard-jasmine-headless-webkit.git'

