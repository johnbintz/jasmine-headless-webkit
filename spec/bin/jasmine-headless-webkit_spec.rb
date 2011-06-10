require 'spec_helper'

describe "jasmine-headless-webkit" do
  let(:report) { 'spec/report.txt' }

  before do
    FileUtils.rm_f report
  end

  after do
    FileUtils.rm_f report
  end

  describe 'success' do
    it "should succeed with error code 0" do
      system %{bin/jasmine-headless-webkit -j spec/jasmine/success/success.yml --report #{report}}
      $?.exitstatus.should == 0

      parts = File.read(report).strip.split('/')
      parts.length.should == 4
      parts[0].should == "1"
      parts[1].should == "0"
      parts[2].should == "F"
    end
  end


  describe 'success but with js error' do
    it "should succeed with error code 0" do
      system %{bin/jasmine-headless-webkit -j spec/jasmine/success_with_error/success_with_error.yml --report #{report}}
      $?.exitstatus.should == 1

      parts = File.read(report).strip.split('/')
      parts.length.should == 4
      parts[0].should == "1"
      parts[1].should == "0"
      parts[2].should == "F"
    end
  end

  describe 'failure' do
    it "should fail with an error code of 1" do
      system %{bin/jasmine-headless-webkit -j spec/jasmine/failure/failure.yml --report #{report}}
      $?.exitstatus.should == 1

      parts = File.read(report).strip.split('/')
      parts.length.should == 4
      parts[0].should == "1"
      parts[1].should == "1"
      parts[2].should == "F"
    end
  end

  describe 'with console.log' do
    it "should succeed, but has a console.log so an error code of 2" do
      system %{bin/jasmine-headless-webkit -j spec/jasmine/console_log/console_log.yml --report #{report}}
      $?.exitstatus.should == 2

      parts = File.read(report).strip.split('/')
      parts.length.should == 4
      parts[0].should == "1"
      parts[1].should == "0"
      parts[2].should == "T"
    end
  end

  describe 'with filtered run' do
    context "don't run a full run, just the filtered run" do
      it "should succeed and run both" do
        system %{bin/jasmine-headless-webkit -j spec/jasmine/filtered_success/filtered_success.yml --no-full-run --report #{report} ./spec/jasmine/filtered_success/success_one_spec.js}
        $?.exitstatus.should == 0

        parts = File.read(report).strip.split('/')
        parts.length.should == 4
        parts[0].should == "1"
        parts[1].should == "0"
        parts[2].should == "F"
      end
    end

    context "do both runs" do
      it "should fail and not run the second" do
        system %{bin/jasmine-headless-webkit -j spec/jasmine/filtered_failure/filtered_failure.yml --report #{report} ./spec/jasmine/filtered_failure/failure_spec.js}
        $?.exitstatus.should == 1

        parts = File.read(report).strip.split('/')
        parts.length.should == 4
        parts[0].should == "1"
        parts[1].should == "1"
        parts[2].should == "F"
      end

      it "should succeed and run both" do
        system %{bin/jasmine-headless-webkit -j spec/jasmine/filtered_success/filtered_success.yml --report #{report} ./spec/jasmine/filtered_success/success_one_spec.js}
        $?.exitstatus.should == 0

        parts = File.read(report).strip.split('/')
        parts.length.should == 4
        parts[0].should == "2"
        parts[1].should == "0"
        parts[2].should == "F"
      end
    end
  end
end

