require 'spec_helper'

describe Jasmine::Headless do
  describe '.warn' do
    let(:output) { StringIO.new }

    before do
      described_class.stubs(:output).returns(output)
    end

    context 'warnings enabled' do
      before do
        described_class.stubs(:show_warnings?).returns(true)
      end

      it 'should work' do
        described_class.warn("warning")

        output.rewind
        output.read.should == "warning\n"
      end
    end

    context 'warnings disabled' do
      before do
        described_class.stubs(:show_warnings?).returns(false)
      end

      it 'should work' do
        described_class.warn("warning")

        output.rewind
        output.read.should == ""
      end
    end
  end
end

