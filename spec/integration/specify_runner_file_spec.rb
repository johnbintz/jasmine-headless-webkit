require 'spec_helper'

describe 'specify runner in jasmine.yml' do
  before do
    File.unlink "spec/temp_out.html" if File.file?('spec/temp_out.html')
  end

  it 'should randomize the run order' do
    output = %x{bin/jasmine-headless-webkit -j spec/jasmine/runner_out_in_jasmine_yml/jasmine.yml}
    $?.exitstatus.should == 2

    output.should include("made it")
    output.should include("1 test")

    "spec/temp_out.html".should be_a_file
  end

  after do
    File.unlink "spec/temp_out.html" if File.file?('spec/temp_out.html')
  end
end

