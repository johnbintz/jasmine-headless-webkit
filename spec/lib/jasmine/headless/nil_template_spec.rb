require 'spec_helper'

describe Jasmine::Headless::NilTemplate do
  include FakeFS::SpecHelpers

  let(:template) { described_class.new(file) { data } }
  let(:file) { 'file' }
  let(:data) { '' }

  subject { template.render }

  before do
    File.open(file, 'wb') if file
  end

  context "no file'" do
    let(:file) { nil }

    it { should == data }
  end

  context 'file' do
    it { should == '' }
  end

  context 'script as first thing' do
    let(:data) { '' }

    it { should == data }
  end
end
