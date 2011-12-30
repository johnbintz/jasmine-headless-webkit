require 'spec_helper'
require 'jasmine/headless/options'
require 'fakefs/spec_helpers'

describe Jasmine::Headless::Options do
  let(:options) { Jasmine::Headless::Options.new(opts) }
  let(:opts) { {} }

  describe '#initialize' do
    let(:default_config) {  'spec/javascripts/support/jasmine.yml' }

    context 'empty' do
      it "should have default options" do
        options[:jasmine_config].should == default_config
      end
    end
    
    context 'with provided' do
      let(:opts) { { :jasmine_config => 'test' } }

      it 'should override an option' do
        options[:jasmine_config].should == 'test'
      end
    end
    
    context 'with nil provided' do
      let(:opts) { { :jasmine_config => nil } }

      it 'should override an option' do
        options[:jasmine_config].should == default_config
      end
    end
  end

  describe '#process_option' do
    it 'should process the option and update the object in place' do
      options[:colors].should be_false
      options[:jasmine_config].should == 'spec/javascripts/support/jasmine.yml'

      options.process_option('--colors')
      options.process_option('-j', 'test')

      options[:colors].should be_true
      options[:jasmine_config].should == 'test'
    end

    context 'legacy reporter' do
      let(:file) { 'file' }

      before do
        options.expects(:warn)
      end

      it 'should add a legacy reporter' do
        options[:reporters] = []

        options.process_option("--report", file)

        options[:reporters].should == [ [ 'File', file ], [ 'Console' ] ]
      end
    end

    context 'short reporter' do
      let(:reporter) { 'reporter' }
      let(:file) { 'file' }

      it 'should add a reporter' do
        options[:reporters] = []

        options.process_option("--format", "#{reporter}:#{file}")

        options[:reporters].should == [ [ reporter, file ] ]
      end
    end
  end

  describe '#read_defaults_files' do
    include FakeFS::SpecHelpers

    let(:global_test_data) { '--colors' }
    let(:test_data) { '-j test' }

    before do
      FileUtils.mkdir_p File.split(Jasmine::Headless::Options::GLOBAL_DEFAULTS_FILE).first
      FileUtils.mkdir_p File.split(Jasmine::Headless::Options::DEFAULTS_FILE).first

      File.open(Jasmine::Headless::Options::GLOBAL_DEFAULTS_FILE, 'w') { |fh| fh.puts global_test_data }
      File.open(Jasmine::Headless::Options::DEFAULTS_FILE, 'w') { |fh| fh.puts test_data }
    end

    it "should read the options" do
      options[:colors].should be_true
      options[:jasmine_config].should == 'test'
    end
  end

  describe '.from_command_line' do
    before do
      @argv = ARGV.dup
    end

    let(:options) { described_class.from_command_line }

    context 'no files specified' do
      before do
        ARGV.replace([])
      end

      it 'should have no files' do
        options[:files].should == []
      end
    end

    context 'files specified' do
      before do
        ARGV.replace([ "test" ])
      end

      it 'should have files' do
        options[:files].should == [ "test" ]
      end
    end

    context 'specify no seed' do
      it 'should have a seed' do
        options[:seed].should_not be_nil
      end
    end

    context 'specify random order seed' do
      let(:seed) { 12345 }

      before do
        ARGV.replace([ "--seed", seed ])
      end

      it 'should specify the seed' do
        options[:seed].should == seed
      end
    end

    let(:test_reporter) { 'TestReporter' }
    let(:file) { 'file' }

    context 'no reporters' do
      it 'should have the default reporter' do
        options[:reporters].should == [ [ 'Console' ] ]
      end
    end

    context 'one reporter' do
      context 'stdout' do
        before do
          ARGV.replace([ "--format", test_reporter ])
        end

        it 'should have the new reporter on stdout' do
          options[:reporters].should == [ [ test_reporter ] ]

          options.reporters.should == [ [ test_reporter, 'stdout' ] ]
        end
      end

      context 'file' do
        before do
          ARGV.replace([ "--format", test_reporter, '--out', file ])
        end

        it 'should have the new reporter on stdout' do
          options[:reporters].should == [ [ test_reporter, file ] ]

          options.reporters.should == [ [ test_reporter, 'report:0', file ] ]
        end
      end
    end

    after do
      ARGV.replace(@argv)
    end
  end

  describe '#file_reporters' do
    subject { options.file_reporters }

    let(:stdout_reporter) { [ 'Console', 'stdout' ] }
    let(:file_reporter) { [ 'File', 'report:0', 'file' ] }

    before do
      options.stubs(:reporters).returns([ stdout_reporter, file_reporter ])
    end

    it { should == [ file_reporter ] }
  end
end
