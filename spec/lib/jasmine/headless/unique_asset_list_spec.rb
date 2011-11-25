require 'spec_helper'

describe Jasmine::Headless::UniqueAssetList do
  let(:list) { described_class.new }

  let(:first) { stub(:logical_path => 'one') }
  let(:second) { stub(:logical_path => 'two') }
  let(:third) { stub(:logical_path => 'two') }

  it 'should raise an exception on a non-asset' do
    expect { list << "whatever" }.to raise_error(StandardError)
  end

  it 'should not add the same asset with the same logical path twice' do
    list << first
    list << second
    list << third

    list.to_a.should == [ first, second ]
  end
end

