require 'spec_helper'

describe Jasmine::Headless::JSTTemplate do
  include FakeFS::SpecHelpers

  let(:template) { described_class.new(file) }
  let(:file) { 'file' }
  let(:data) { 'data' }

  let(:context) { stub(:logical_path => 'path') }

  before do
    File.open(file, 'wb') { |fh| fh.print data }
  end

  subject { template.render(context) }

  it { should include(%{<script type="text/javascript">}) }
  it { should include(data) }
end

