require 'spec_helper'
require 'fakefs/spec_helpers'
require 'jasmine/headless/runner'

describe Jasmine::Headless::Runner do
  let(:runner) { Jasmine::Headless::Runner.new(options) }
  let(:options) { Jasmine::Headless::Options.new(opts) }

  describe '#initialize' do
    let(:opts) { { :test => 'test', :jasmine_config => nil } }

    it 'should have default options' do
      runner.options[:test].should == 'test'
      runner.options[:jasmine_config].should == 'spec/javascripts/support/jasmine.yml'
    end
  end

  describe '#load_config' do
    include FakeFS::SpecHelpers

    let(:opts) { { :jasmine_config => 'test.yml' } }

    before do
      File.open(Jasmine::Headless::Runner::RUNNER, 'w')
      File.open('test.yml', 'w') { |fh| fh.print YAML.dump('test' => 'hello') }
    end

    it 'should load the jasmine config' do
      runner.jasmine_config['test'].should == 'hello'
      runner.jasmine_config['spec_dir'].should == 'spec/javascripts'
    end
  end

  describe '#jasmine_command' do
    let(:opts) { {
      :colors => true,
      :report => 'test'
    } }

    it 'should have the right options' do
      runner.jasmine_command.should match(/jasmine-webkit-specrunner/)
      runner.jasmine_command.should match(/-c/)
      runner.jasmine_command.should match(/-r test/)
      runner.jasmine_command('file.js').should match(/file.js/)
    end
  end

  context 'real tests' do
    let(:report) { 'spec/report.txt' }

    before do
      FileUtils.rm_f report
    end

    after do
      FileUtils.rm_f report
    end

    it 'should succeed with error code 0' do
      Jasmine::Headless::Runner.run(
        :jasmine_config => 'spec/jasmine/success/success.yml',
        :report => report
      ).should == 0

      report.should be_a_report_containing(1, 0, false)
    end

    it 'should succeed but with javascript error' do
      Jasmine::Headless::Runner.run(:jasmine_config => 'spec/jasmine/success_with_error/success_with_error.yml').should == 1
    end

    it 'should fail on one test' do
      Jasmine::Headless::Runner.run(
        :jasmine_config => 'spec/jasmine/failure/failure.yml',
        :report => report
      ).should == 1

      report.should be_a_report_containing(1, 1, false)
      report.should contain_a_failing_spec(['failure', 'should fail with error code of 1'])
    end
  end
end
