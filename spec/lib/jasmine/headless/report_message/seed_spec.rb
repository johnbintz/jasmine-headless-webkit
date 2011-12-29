require 'spec_helper'

describe Jasmine::Headless::ReportMessage::Seed do
  let(:seed) { described_class.new(seed_value) }
  let(:seed_value) { '1' }

  subject { seed }

  its(:seed) { should == seed_value.to_i }

  describe '.new_from_parts' do
    subject { described_class.new_from_parts(parts) }

    let(:parts) { [ seed_value ] }

    its(:seed) { should == seed_value.to_i }
  end
end
