require 'spec_helper'

describe Jasmine::Headless::FileChecker do
  include FakeFS::SpecHelpers

  let(:test_class) do
    object = Object.new
    object.class.send(:include, Jasmine::Headless::FileChecker)
    object
  end

  context "bad_format?" do
    it "should return false wth correct format" do
      test_class.bad_format?('foobar.js').should be_false
    end

    it "should return false wth wrong format" do
      test_class.bad_format?('foobar.js.erb').should be_true
    end

    it "should check for the whole extension" do
      test_class.bad_format?('foobar.string.js').should be_false
    end
  end
end
