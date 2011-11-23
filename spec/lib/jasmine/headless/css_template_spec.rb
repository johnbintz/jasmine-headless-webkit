require 'spec_helper'

describe Jasmine::Headless::CSSTemplate do
  include FakeFS::SpecHelpers

  let(:template) { described_class.new(file) { data } }
  let(:file) { 'file' }
  let(:data) { 'data' }

  subject { template.render }

  before do
    File.open(file, 'wb') if file
  end

  context "no file'" do
    let(:file) { nil }

    it { should == data }
  end

  context 'file' do
    it { should == %{<link rel="stylesheet" href="#{file}" type="text/css" />} }
  end
end
