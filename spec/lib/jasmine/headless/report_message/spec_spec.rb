require 'spec_helper'

describe Jasmine::Headless::ReportMessage::Spec do
  subject { spec }

  context 'with filename' do
    let(:filename) { 'file.js' }
    let(:spec) { described_class.new("Test", "#{filename}:23") }

    its(:filename) { should == filename }
  end

  context 'without filename' do
    let(:filename) { 'file.js' }
    let(:spec) { described_class.new("Test", "") }

    its(:filename) { should be_nil }
  end
end

