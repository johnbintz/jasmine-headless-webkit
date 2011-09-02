require 'spec_helper'

describe Jasmine::Headless::Report do
  include FakeFS::SpecHelpers

  describe '.load' do
    context 'no file' do
      it 'should raise an exception' do
        expect { described_class.load(file) }.to raise_error(Errno::ENOENT)
      end
    end

    context 'file' do

    end
  end
end

