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
    let(:test_data) { %w{first second} }

    before do
      File.open(DEFAULTS_FILE, 'w') { |fh| fh.puts test_data.join(' ') }
    end

    it "should read the options" do
      found = false

      @process_options = lambda { |*args|
        found = true if args.flatten == test_data
      }

      read_defaults_file

      found.should be_true
    end
  end
end
