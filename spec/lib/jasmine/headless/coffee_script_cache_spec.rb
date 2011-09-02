require 'spec_helper'

describe Jasmine::Headless::CoffeeScriptCache do
  include FakeFS::SpecHelpers

  describe '#action' do
    let(:file) { 'file' }
    let(:data) { 'data' }
    let(:compiled) { 'compiled' }

    before do
      CoffeeScript.expects(:compile).with(data).returns(compiled)
      File.open(file, 'wb') { |fh| fh.print(data) }
    end

    it 'should compile coffeescript' do
      described_class.new(file).action.should == compiled
    end
  end
end

