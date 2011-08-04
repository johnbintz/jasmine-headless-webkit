include Rake::DSL if defined?(Rake::DSL)

require 'bundler'
Bundler::GemHelper.install_tasks

begin
  require 'hydra'
  require 'hydra/tasks'
  require 'facter'

  Hydra::TestTask.new('hydra:spec') do |t|
    t.add_files 'spec/**/*_spec.rb'
  end
rescue LoadError
  warn "$! - hydra not loaded"
end

HYDRA_LOG = 'hydra-runner.log'

task 'hydra:before' do
  rm HYDRA_LOG if File.file?(HYDRA_LOG)
end

task('hydra:spec').enhance(%w{hydra:before}) do
  puts File.read(HYDRA_LOG) if File.file?(HYDRA_LOG)
end

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
        system %{bash -c 'source ~/.rvm/scripts/rvm ; rvm #{version} ; bundle install ; bundle exec rake hydra:spec'}
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
