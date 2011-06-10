require 'spec_helper'
require 'jasmine/cli'
require 'fakefs/spec_helpers'

describe Jasmine::CLI do
  include Jasmine::CLI
  include FakeFS::SpecHelpers

  describe '#process_jasmine_config' do
    context 'without overrides' do
      let(:config) { {} }

      it "should just return the defaults" do
        process_jasmine_config(config).should == {
          'src_files' => [],
          'stylesheets' => [],
          'helpers' => [ 'helpers/**/*.js' ],
          'spec_files' => [ '**/*[sS]pec.js' ],
          'src_dir' => nil,
          'spec_dir' => 'spec/javascripts'
        }
      end
    end

    context 'with overrides' do
      let(:config) {
        { 
          'src_files' => [ 'one', 'two' ],
          'src_dir' => 'this-dir',
          'stylesheets' => [ 'three', 'four' ],
          'helpers' => [ 'five', 'six' ],
          'spec_files' => [ 'seven', 'eight' ],
          'spec_dir' => 'that-dir'
        } 
      }

      it "should return the merged data" do
        process_jasmine_config(config).should == config
      end
    end
  end

  describe '#read_defaults_file' do
    let(:global_test_data) { %w{first second} }
    let(:test_data) { %w{third fourth} }

    before do
      File.open(Jasmine::CLI::GLOBAL_DEFAULTS_FILE, 'w') { |fh| fh.puts global_test_data.join(' ') }
      File.open(Jasmine::CLI::DEFAULTS_FILE, 'w') { |fh| fh.puts test_data.join(' ') }
    end

    it "should read the options" do
      all_data = []
      @process_options = lambda { |*args| all_data << args.flatten }

      read_defaults_files!

      all_data.should == [ global_test_data, test_data ]
    end
  end
end
