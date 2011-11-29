if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

if ENV['PROFILE']
  require 'perftools'
  PerfTools::CpuProfiler.start("/tmp/jhw-profile")
end

require 'jasmine-headless-webkit'
require 'fakefs/spec_helpers'

RSpec.configure do |c|
  c.mock_with :mocha
  c.backtrace_clean_patterns = []
  
  c.before(:each) do
    Jasmine::Headless::CacheableAction.enabled = false
    Jasmine::Headless::FilesList.reset!
  end

  c.before(:each, :type => :integration) do
    let(:report) { 'spec/report.txt' }

    before do
      FileUtils.rm_f report
    end

    after do
      FileUtils.rm_f report
    end
  end
end

specrunner = 'ext/jasmine-webkit-specrunner/jasmine-webkit-specrunner'

if !File.file?(specrunner)
  Dir.chdir File.split(specrunner).first do
    system %{ruby extconf.rb}
  end
end

class FakeFS::File
  class << self
    def fnmatch?(pattern, file)
      RealFile.fnmatch?(pattern, file)
    end
  end

  class Stat
    def file?
      File.file?(@file)
    end
  end
end

module RSpec::Matchers
  define :be_a_report_containing do |total, failed, used_console|
    match do |filename|
      report(filename)
      report.total.should == total
      report.failed.should == failed
      report.has_used_console?.should == used_console
      true
    end

    failure_message_for_should do |filename|
      "expected #{filename} to be a report containing (#{total}, #{failed}, #{used_console.inspect})"
    end

    def report(filename = nil)
      @report ||= Jasmine::Headless::Report.load(filename)
    end
  end

  define :contain_a_failing_spec do |*parts|
    match do |filename|
      report(filename).should have_failed_on(parts.join(" "))
    end

    def report(filename)
      @report ||= Jasmine::Headless::Report.load(filename)
    end
  end

  define :be_a_file do
    match do |file|
      File.file?(file)
    end
  end

  define :contain_in_order_in_file_list do |*files|
    match do |lines|
      file_list = files.dup

      lines.each do |line|
        next if !file_list.first

        if line[file_list.first]
          file_list.shift
        end
      end

      file_list.length == 0
    end

    failure_message_for_should do |lines|
      %{expected\n#{lines.join("\n")}\nto contain the following files, in order:\n#{files.join("\n")}}
    end
  end
end

