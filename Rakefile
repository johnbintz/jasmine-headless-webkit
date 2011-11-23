include Rake::DSL if defined?(Rake::DSL)

require 'bundler'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

$: << File.expand_path('../lib', __FILE__)

require 'jasmine-headless-webkit'
require 'jasmine/headless/task'

Jasmine::Headless::Task.new

PLATFORMS = %w{1.8.7 1.9.2 ree 1.9.3-rc1}

def rvm_bundle(command = '')
  Bundler.with_clean_env do
    system %{bash -c 'unset BUNDLE_BIN_PATH && unset BUNDLE_GEMFILE && rvm #{PLATFORMS.join(',')} do bundle #{command}'}
  end
end

class SpecFailure < StandardError; end
class BundleFailure < StandardError; end

namespace :spec do
  desc "Run on three Rubies"
  task :platforms do
    rvm_bundle
    rvm_bundle "exec rspec spec"
    raise SpecError.new if $?.exitstatus != 0
  end
end

task :default => [ 'spec:platforms', 'jasmine:headless' ]

desc "Build the runner"
task :build_runner do
  Dir.chdir 'ext/jasmine-webkit-specrunner' do
    system %{ruby extconf.rb}
  end
end

desc "Generate vendored JS"
task :generate_js do
  require 'sprockets'

  source = 'vendor/assets/coffeescripts'
  target = 'vendor/assets/javascripts'

  env = Sprockets::Environment.new { |s| s.append_path 'vendor/assets/coffeescripts' }

  Dir[File.join(File.expand_path(source), '*.coffee')].each do |file|
    file_target = file.gsub(source, target).gsub('.coffee', '.js')
    puts "#{file} => #{file_target}"

    File.open(file_target, 'wb') do |fh|
      fh.print env.find_asset(File.expand_path(file)).to_s
    end
  end
end

