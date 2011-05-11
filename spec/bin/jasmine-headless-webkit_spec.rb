require 'spec_helper'

describe "jasmine-headless-webkit" do
  describe 'success' do
    it "should succeed with error code 0" do
      %x{bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml}
      $?.exitstatus.should == 0
    end
  end

  describe 'failure' do
    it "should fail with an error code of 1" do
      %x{bin/jasmine-headless-webkit -j spec/jasmine/failure/failure.yml}
      $?.exitstatus.should == 1
    end
  end

  describe 'with console.log' do
    it "should succeed, but has a console.log so an error code of 2" do
      %x{bin/jasmine-headless-webkit -j spec/jasmine/console_log/console_log.yml}
      $?.exitstatus.should == 2
    end
  end
end

