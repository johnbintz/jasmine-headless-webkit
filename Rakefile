include Rake::DSL if defined?(Rake::DSL)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

$: << File.expand_path('../lib', __FILE__)

require 'jasmine/headless/task'

Jasmine::Headless::Task.new

namespace :spec do
  desc "Run on three Rubies"
  task :platforms do
    system %{rvm 1.8.7,1.9.2,ree ruby bundle}
    system %{rvm 1.8.7,1.9.2,ree ruby bundle exec rake spec}
    raise StandardError.new if $?.exitstatus != 0
  end
end

task :default => [ 'spec:platforms', 'jasmine:headless' ]

desc "Build the runner"
task :build do
  Dir.chdir 'ext/jasmine-headless-specrunner' do
    system %{ruby extconf.rb}
  end
end
