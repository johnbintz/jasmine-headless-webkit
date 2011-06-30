# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jasmine-headless-webkit/version"

Gem::Specification.new do |s|
  s.name        = "jasmine-headless-webkit"
  s.version     = Jasmine::Headless::Webkit::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["John Bintz", "Sencha Inc.", "Pivotal Labs"]
  s.email       = ["john@coswellproductions.com"]
  s.homepage    = ""
  s.summary     = %q{Run Jasmine specs headlessly in a WebKit browser}
  s.description = %q{Run Jasmine specs headlessly}

  s.rubyforge_project = "jasmine-headless-webkit"

  s.extensions    = `git ls-files -- ext/**/extconf.rb`.split("\n")
  s.files         = `git ls-files`.split("\n") + Dir['jasmine/lib/*']
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'jasmine', '~>1.1.beta'
  s.add_dependency 'coffee-script', '>= 2.2'
  s.add_dependency 'rainbow'
end
