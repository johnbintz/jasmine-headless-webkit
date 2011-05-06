require 'spec_helper'
require 'jasmine/cli'

describe Jasmine::CLI do
  include Jasmine::CLI

  describe '#process_jasmine_config' do
    context 'without overrides' do
      let(:config) { {} }

      it "should just return the defaults" do
        process_jasmine_config(config).should == {
          'src_files' => [],
          'stylesheets' => [],
          'helpers' => [ 'helpers/**/*.js' ],
          'spec_files' => [ '**/*[sS]pec.js' ],
          'src_dir' => '',
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

  describe '#get_files' do

  end
end
