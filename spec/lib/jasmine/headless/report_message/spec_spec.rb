require 'spec_helper'

describe Jasmine::Headless::ReportMessage::Spec do
  let(:filename) { 'file.js' }
  let(:spec) { described_class.new("Test", "#{filename}:23") }

  subject { spec }

  its(:filename) { should == filename }
end

