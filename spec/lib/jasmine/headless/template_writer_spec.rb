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

  describe '#render' do
    subject { template_writer.render }

    let(:all_files) { 'all files' }
    let(:template) { 'template' }

    before do
      template_writer.stubs(:all_files).returns(all_files)

      template_writer.expects(:template_for).with(all_files).returns(template)
    end

    it { should == template }
  end

  describe '#all_files' do
    subject { template_writer.all_files }

    let(:files_list) { stub }
    let(:files) { 'files' }

    before do
      template_writer.stubs(:files_list).returns(files_list)

      files_list.stubs(:files_to_html).returns(files)
    end

    it { should == files }
  end

  describe '#jhw_reporters' do
    subject { template_writer.jhw_reporters }

    let(:reporter) { 'reporter' }
    let(:output) { 'output' }

    before do
      template_writer.stubs(:reporters).returns([
        [ reporter, output ]
      ])
    end

    it { should include(reporter) }
    it { should include(output) }
  end
end

