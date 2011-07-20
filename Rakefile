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
    current = %x{rvm-prompt v}
    
    fail = false
    %w{1.8.7 1.9.2 ree}.each do |version|
      puts "Switching to #{version}"
      Bundler.with_clean_env do
        system %{bash -c 'source ~/.rvm/scripts/rvm ; rvm #{version} ; bundle install ; bundle exec rake spec'}
      end
      if $?.exitstatus != 0
        fail = true
        break
      end
    end

    system %{rvm #{current}}

    exit (fail ? 1 : 0)
  end
end

task :default => [ 'spec:platforms', 'jasmine:headless' ]

desc "Build the runner"
task :build do
  Dir.chdir 'ext/jasmine-headless-specrunner' do
    system %{ruby extconf.rb}
  end
end
