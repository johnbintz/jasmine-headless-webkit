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

    it 'should have a template writer' do
      runner.template_writer.should be_a_kind_of(Jasmine::Headless::TemplateWriter)
      runner.template_writer.runner.should == runner
    end
  end

  describe '#load_config' do
    include FakeFS::SpecHelpers

    let(:runner_filename) { 'ext/jasmine-webkit-specrunner/jasmine-webkit-specrunner' }

    before do
      FileUtils.mkdir_p File.split(runner_filename).first

      File.open(runner_filename, 'w')
    end

    let(:config_filename) { 'test.yml' }
    let(:opts) { { :jasmine_config => config_filename } }

    context 'file exists' do
      before do
        File.open(config_filename, 'w') { |fh| fh.print YAML.dump('test' => 'hello', 'erb' => '<%= "erb" %>') }
      end

      it 'should load the jasmine config' do
        runner.jasmine_config['test'].should == 'hello'
        runner.jasmine_config['spec_dir'].should == 'spec/javascripts'
      end

      it 'should execute ERB in the config file' do
        runner.jasmine_config['erb'].should == 'erb'
      end
    end

    context 'file does not exist' do
      it 'should raise an exception' do
        expect { runner.jasmine_config }.to raise_error(Jasmine::Headless::JasmineConfigNotFound, /#{config_filename}/)
      end
    end
  end

  describe '#jasmine_command' do
    subject { runner.jasmine_command(target) }

    let(:target) { 'target' }

    let(:options) { {} }
    let(:reporters) { [] }

    before do
      runner.stubs(:options).returns(options)
      options.stubs(:file_reporters).returns(reporters)
    end

    def self.it_should_have_basics
      it { should include(target) }
    end

    context 'colors' do
      before do
        options[:colors] = true
      end

      it_should_have_basics
      it { should include('-c') }
    end

    context 'reporters' do
      let(:reporter) { [ 'Reporter', 'identifier', file ] }
      let(:reporters) { [ reporter ] }

      let(:file) { 'file' }

      it_should_have_basics
      it { should include("-r #{file}") }
    end

    context 'quiet' do
      before do
        options[:quiet] = true
      end

      it_should_have_basics
      it { should include("-q") }
    end
  end

  describe '#runner_filename' do
    let(:runner_filename) { runner.runner_filename }
    let(:yaml_output) { 'yaml output' }

    context 'not in options' do
      let(:opts) { { :runner_output_filename => false } }

      context 'not in yaml file' do
        before do
          runner.stubs(:jasmine_config).returns('runner_output' => '')
        end

        it 'should reverse the remove_html_file option' do
          runner_filename.should == false
        end
      end

      context 'in yaml file' do
        before do
          runner.stubs(:jasmine_config).returns('runner_output' => yaml_output)
        end

        it 'should use the yaml file definition' do
          runner_filename.should == yaml_output
        end
      end
    end
    
    context 'in options' do
      let(:filename) { 'filename.html' }
      let(:opts) { { :runner_output_filename => filename } }

      context 'not in yaml file' do
        before do
          runner.stubs(:jasmine_config).returns('runner_output' => '')
        end

        it 'should reverse the remove_html_file option' do
          runner.runner_filename.should == filename
        end
      end

      context 'in yaml file' do
        before do
          runner.stubs(:jasmine_config).returns('runner_output' => yaml_output)
        end

        it 'shoulduse the command line filename' do
          runner.runner_filename.should == filename
        end
      end
    end
  end

  describe '#jasmine_config' do
    let(:opts) { {} }

    before do
      runner.stubs(:jasmine_config_data).returns('spec_files' => nil)
    end

    it 'should not merge in things with nil values' do
      runner.jasmine_config['spec_files'].should == described_class::JASMINE_DEFAULTS['spec_files']
    end
  end

  describe '#files_list' do
    subject { runner.files_list }

    let(:options) { { :files => only, :seed => seed } }

    let(:only) { 'only' }
    let(:seed) { 12345 }
    let(:jasmine_config) { 'jasmine config' }
    let(:reporters) { [] }

    before do
      runner.stubs(:options).returns(options)
      runner.stubs(:jasmine_config).returns(jasmine_config)

      options.stubs(:reporters).returns(reporters)
    end

    it { should be_a_kind_of(Jasmine::Headless::FilesList) }

    it 'should have settings' do
      subject.options[:config].should == jasmine_config
      subject.options[:only].should == only
      subject.options[:seed].should == seed
      subject.options[:reporters].should == reporters
    end
  end

  describe '.server_port' do
    before do
      described_class.instance_variable_set(:@server_port, nil)
    end

    context 'port in use' do
      require 'socket'

      before do
        described_class.stubs(:select_server_port).returns(5000, 5001)
      end

      it 'should try another port' do
        server = TCPServer.new(described_class.server_interface, 5000)

        described_class.server_port.should == 5001
      end
    end
  end

  describe '#absolute_run_targets' do
    let(:opts) { {} }

    subject { runner.absolute_run_targets(targets) }

    let(:targets) { [ target ] }
    let(:target) { 'target' }

    before do
      runner.stubs(:options).returns(:use_server => use_server)
    end

    context 'server' do
      let(:use_server) { true }
      let(:server_spec_path) { 'server spec path' }

      before do
        described_class.stubs(:server_spec_path).returns(server_spec_path)
      end

      it { should == [ server_spec_path + target ] }
    end

    context 'no server' do
      let(:use_server) { false }

      it { should == [ 'file://' + File.expand_path(target) ] }
    end
  end
end
