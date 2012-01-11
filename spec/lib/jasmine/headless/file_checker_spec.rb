require 'spec_helper'

describe Jasmine::Headless::FileChecker do
  let(:test_class) do
    object = Object.new
    object.class.send(:include, Jasmine::Headless::FileChecker)
    object
  end

  describe "#bad_format?" do
    subject { test_class.bad_format?(file) }

    before do
      test_class.stubs(:excluded_formats).returns(%w{erb string})
    end

    context 'nil' do
      let(:file) { nil }

      it { should be_nil }
    end

    context 'allowed format' do
      let(:file) { 'foobar.js' }

      it { should be_false }
    end

    context 'unallowed format' do
      let(:file) { 'foobar.erb' }

      it { should be_true }
    end

    context 'check whole extension' do
      let(:file) { 'foobar.string.js' }

      it { should be_true }
    end
  end
end
