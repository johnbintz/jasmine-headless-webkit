require 'spec_helper'

describe Jasmine::Headless::PathSearcher do
  include FakeFS::SpecHelpers

  let(:path) { File.expand_path('path') }
  let(:paths) { [ path ] }
  let(:source) { stub(:search_paths => paths, :extension_filter => %r{.*}) }
  let(:path_searcher) { described_class.new(source) }

  let(:filename) { 'file.js' }

  let(:file) { File.join(path, filename) }

  describe '#find' do
    subject { path_searcher.find(search) }

    before do
      FileUtils.mkdir_p path
      File.open(file, 'wb')
    end

    context 'found file' do
      let(:search) { 'file' }

      it 'should find the file' do
        subject.should == [ File.expand_path(file), path ]
      end
    end

    context 'not found file' do
      let(:search) { 'other' }

      it 'should not find the file' do
        subject.should be_false
      end
    end
  end
end

