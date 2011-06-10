require 'spec_helper'
require 'jasmine/template_writer'
require 'fakefs/spec_helpers'

describe Jasmine::TemplateWriter do
  describe '.write!' do
    include FakeFS::SpecHelpers

    let(:files_list) { Jasmine::FilesList.new }

    before do
      files_list.files << 'file.js'
      files_list.filtered_files << 'file.js'
    end

    context 'no filter' do
      it 'should write one file' do
        Jasmine::TemplateWriter.write!(files_list).should == [
          "specrunner.#{$$}.html"
        ]
      end
    end

    context 'filtered files' do
      before do
        files_list.files << 'file2.js'
      end

      it 'should write two files' do
        Jasmine::TemplateWriter.write!(files_list).should == [
          "specrunner.#{$$}.filter.html", "specrunner.#{$$}.html"
        ]
      end
    end
  end
end

