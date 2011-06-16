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
  end

  describe '#read_defaults_files' do
    include FakeFS::SpecHelpers

    let(:global_test_data) { '--colors' }
    let(:test_data) { '-j test' }

    before do
      File.open(Jasmine::Headless::Options::GLOBAL_DEFAULTS_FILE, 'w') { |fh| fh.puts global_test_data }
      File.open(Jasmine::Headless::Options::DEFAULTS_FILE, 'w') { |fh| fh.puts test_data }
    end

    it "should read the options" do
      options[:colors].should be_false
      options[:jasmine_config].should == 'spec/javascripts/support/jasmine.yml'

      options.read_defaults_files

      options[:colors].should be_true
      options[:jasmine_config].should == 'test'
    end
  end
end
