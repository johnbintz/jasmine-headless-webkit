require 'spec_helper'
require 'fakefs/spec_helpers'

describe Jasmine::Headless::TemplateWriter do
  let(:runner) { stub }
  let(:template_writer) { described_class.new(runner) }

  describe '#all_tests_filename' do
    let(:all_tests_filename) { template_writer.all_tests_filename }

    context 'runner does not care about filename' do
      before do
        runner.stubs(:runner_filename).returns(false)
      end

      it 'should use a specrunner.html file' do
        all_tests_filename.should_not include('tmp')
        all_tests_filename.should include('jhw')
        all_tests_filename.should include('.html')
      end
    end

    context 'runner cares about filename' do
      let(:filename) { 'filename.html' }

      before do
        runner.stubs(:runner_filename).returns(filename)
      end

      it 'should use a specrunner.html file' do
        all_tests_filename.should == filename
      end
    end
  end

  describe '#filtered_tests_filename' do
    before do
      template_writer.stubs(:all_tests_filename).returns("test.html")
    end

    it 'should filter the filename for all tests' do
      template_writer.filtered_tests_filename.should == 'test.filter.html'
    end
  end

  describe '#write!' do
    include FakeFS::SpecHelpers

    before do
      Jasmine::Headless::FilesList.stubs(:default_files).returns([])

      File.stubs(:read).returns(nil)

      runner.stubs(:keep_runner).returns(true)
      runner.stubs(:runner_filename).returns(false)

      Sprockets::Environment.any_instance.stubs(:find_asset).returns(stub(:body => ''))
    end

    let(:files_list) { Jasmine::Headless::FilesList.new }

    before do
      files_list.stubs(:files).returns([ 'file.js' ])
      files_list.stubs(:filtered_files).returns([ 'file.js' ])
    end

    context 'no filter' do
      it 'should write one file' do
        template_writer.write!(files_list).should == [
          "jhw.#{$$}.html"
        ]
      end
    end

    context 'filtered files' do
      before do
        files_list.stubs(:files).returns([ 'file.js', 'file2.js' ])
      end

      it 'should write two files' do
        template_writer.write!(files_list).should == [
          "jhw.#{$$}.filter.html", "jhw.#{$$}.html"
        ]
      end
    end
  end
end

