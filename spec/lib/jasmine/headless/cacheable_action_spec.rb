require 'spec_helper'

describe Jasmine::Headless::CacheableAction do
  include FakeFS::SpecHelpers

  let(:file) { 'dir/file.whatever' }
  let(:data) { 'data' }
  let(:compiled) { 'compiled' }

  before do
    FileUtils.mkdir_p File.dirname(file)

    File.open(file, 'wb') { |fh| fh.print(data) }

    described_class.cache_dir = cache_dir
    described_class.cache_type = cache_type
  end

  let(:action_runs!) do
    described_class.any_instance.expects(:action).returns(compiled)
  end

  let(:cache_type) { 'action' }
  let(:cache_dir) { 'cache' }
  let(:cache_file) { File.join(cache_dir, cache_type, file) + '.js' }
  let(:cache_file_data) { YAML.load(File.read(cache_file)) }

  let(:cache_object) { described_class.new(file) }

  describe '.for' do
    context 'cache disabled' do
      before do
        described_class.enabled = false
      end

      it 'should compile' do
        action_runs!
        described_class.for(file).should == compiled
        cache_file.should_not be_a_file

        cache_object.should_not be_cached
      end
    end

    context 'cache enabled' do
      before do
        described_class.enabled = true
        FileUtils.mkdir_p(cache_dir)

        File.stubs(:mtime).with(file).returns(Time.at(10))
        File.stubs(:mtime).with(File.expand_path(cache_file)).returns(Time.at(cache_file_mtime))
      end

      context 'cache empty' do
        let(:cache_file_mtime) { 0 }

        it 'should compile' do
          action_runs!
          described_class.for(file).should == compiled

          cache_file_data.should == compiled
          cache_object.should be_cached
        end
      end

      context 'cache fresh' do
        let(:cache_file_mtime) { 15 }

        before do
          FileUtils.mkdir_p File.split(cache_file).first
          File.open(cache_file, 'wb') { |fh| fh.print compiled }
        end

        it 'should not compile' do
          action_runs!.never

          described_class.for(file).should == compiled

          cache_file_data.should == compiled
          cache_object.should be_cached
        end
      end

      context 'cache stale' do
        let(:cache_file_mtime) { 5 }

        it 'should compile' do
          action_runs!

          described_class.for(file).should == compiled

          cache_file_data.should == compiled
          cache_object.should be_cached
        end
      end
    end
  end
end

