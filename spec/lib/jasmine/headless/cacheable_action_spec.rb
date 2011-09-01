require 'spec_helper'

describe Jasmine::Headless::CacheableAction do
  include FakeFS::SpecHelpers

  let(:file) { 'file.whatever' }
  let(:data) { 'data' }
  let(:compiled) { 'compiled' }

  before do
    File.open(file, 'wb') { |fh| fh.print(data) }
    described_class.cache_dir = cache_dir
    described_class.cache_type = cache_type
  end

  let(:action_runs!) do
    described_class.any_instance.expects(:action).returns(compiled)
  end

  let(:cache_type) { 'action' }
  let(:cache_dir) { 'cache' }
  let(:cache_file) { File.join(cache_dir, cache_type, Digest::SHA1.hexdigest(file)) }
  let(:cache_file_data) { YAML.load(File.read(cache_file)) }

  describe '.for' do
    context 'cache disabled' do
      before do
        described_class.enabled = false
      end

      it 'should compile' do
        action_runs!
        described_class.for(file).should == compiled
        cache_file.should_not be_a_file
      end
    end

    context 'cache enabled' do
      before do
        described_class.enabled = true
        FileUtils.mkdir_p(cache_dir)

        File.stubs(:mtime).with(file).returns(Time.at(10))
        File.stubs(:mtime).with(cache_file).returns(Time.at(cache_file_mtime))
      end

      context 'cache empty' do
        let(:cache_file_mtime) { 0 }

        it 'should compile' do
          action_runs!
          described_class.for(file).should == compiled

          cache_file_data.should == compiled
        end
      end

      context 'cache fresh' do
        let(:cache_file_mtime) { 15 }

        before do
          File.open(cache_file, 'wb') { |fh| fh.print compiled }
        end

        it 'should not compile' do
          action_runs!.never

          described_class.for(file).should == compiled

          cache_file_data.should == compiled
        end
      end

      context 'cache stale' do
        let(:cache_file_mtime) { 5 }

        it 'should compile' do
          action_runs!

          described_class.for(file).should == compiled

          cache_file_data.should == compiled
        end
      end
    end
  end
end

