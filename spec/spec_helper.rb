require 'jasmine-headless-webkit'
require 'fakefs/spec_helpers'

RSpec.configure do |c|
  c.mock_with :mocha
  
  c.before(:each) do
    Jasmine::Headless::CacheableAction.enabled = false
  end
end

specrunner = 'ext/jasmine-webkit-specrunner/jasmine-webkit-specrunner'

if !File.file?(specrunner)
  Dir.chdir File.split(specrunner).first do
    system %{ruby extconf.rb}
  end
end

module RSpec::Matchers
  define :be_a_report_containing do |total, fails, used_console|
    match do |filename|
      parts(filename).length.should == 4
      parts[0].should == total.to_s
      parts[1].should == fails.to_s
      parts[2].should == (used_console ? "T" : "F")
      true
    end

    failure_message_for_should do |filename|
      parts(filename)
      "expected #{filename} to be a report containing (#{total}, #{fails}, #{used_console.inspect}), instead it contained (#{parts[0]}, #{parts[1]}, #{(parts[2] == "T").inspect})"
    end

    def parts(filename = nil)
      @parts ||= File.readlines(filename).first.strip.split('/')
    end
  end

  define :contain_a_failing_spec do |*parts|
    match do |filename|
      report(filename).include?(parts.join("||")).should be_true
    end

    def report(filename)
      @report ||= File.readlines(filename)[1..-1].collect(&:strip)
    end
  end

  define :be_a_file do
    match do |file|
      File.file?(file)
    end
  end
end
