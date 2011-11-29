require 'spec_helper'

describe Jasmine::Headless::JSTemplate do
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
    it { should == %{<script type="text/javascript" src="#{file}"></script>} }
  end

  context 'script as first thing' do
    let(:data) { '<script type="text/javascript"' }

    it { should == data }
  end
end
