require 'spec_helper'

describe Jasmine::Headless::TestFile do
  let(:source_root) { File.expand_path('source_root') }
  let(:path) { File.join(source_root, 'path.js') }

  let(:file) { described_class.new(path, source_root) }

  subject { file }

  its(:path) { should == path }

  describe '#to_html' do
    subject { file.to_html }

    context '.js' do
      let(:path) { 'path.js' }

      it { should == %{<script type="text/javascript" src="#{path}"></script>} }
    end

    context '.css' do
      let(:path) { 'path.css' }

      it { should == %{<link rel="stylesheet" href="#{path}" type="text/css" />} }
    end

    context '.coffee' do
      let(:path) { 'path.coffee' }

      let(:handle_expectation) { Jasmine::Headless::CoffeeScriptCache.any_instance.stubs(:handle) }

      context 'compilation error' do
        let(:error) { CoffeeScript::CompilationError.new("fail") }

        before do
          handle_expectation.raises(error)
        end

        it 'should pass along the error' do
          expect { subject }.to raise_error(CoffeeScript::CompilationError)
        end
      end

      context 'compiles fine' do
        let(:source) { 'source' }

        before do
          Jasmine::Headless::CoffeeScriptCache.any_instance.stubs(:cached?).returns(cache_return)
          handle_expectation.returns(source)
        end

        context 'cached' do
          let(:file_path) { 'dir/file.js' }
          let(:cache_return) { true }

          before do
            Jasmine::Headless::CoffeeScriptCache.any_instance.stubs(:cache_file).returns(file_path)
          end

          it 'should return the cached file' do
            subject.should include(%{<script type="text/javascript" src="#{file_path}"></script>})
          end
        end

        context 'not cached' do
          let(:cache_return) { false }

          it 'should return the generated js' do
            subject.should include(%{<script type="text/javascript">#{source}</script>})
          end
        end
      end
    end
  end

  describe '#dependencies' do
    include FakeFS::SpecHelpers

    before do
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'wb') { |fh| fh.print "//= require '#{req}'\njavascript" }
    end

    context 'absolute' do
      let(:req) { 'test' }

      subject { file.dependencies }

      it { should == [ [ 'require', req ] ] }
    end

    context 'relative' do
      let(:path) { File.join(source_root, 'subdir/subsubdir/path.js') }

      let(:req) { './test' }

      subject { file.dependencies }

      it { should == [ [ 'require', 'subdir/subsubdir/test' ] ] }
    end

    context 'dot' do
      let(:path) { File.join(source_root, 'subdir/subsubdir/path.js') }

      let(:req) { '.' }

      subject { file.dependencies }

      it { should == [ [ 'require', 'subdir/subsubdir' ] ] }
    end
  end
end
