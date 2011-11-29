require 'spec_helper'

describe 'randomize run order' do
  let(:seed) { 100 }

  it 'should randomize the run order' do
    output = %x{bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml --seed #{seed}}
    $?.exitstatus.should == 0

    output.should include("--seed #{seed}")
  end
end

