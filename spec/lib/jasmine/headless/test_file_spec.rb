require 'spec_helper'

describe Jasmine::Headless::TestFile do
  let(:file) { described_class.new(path) }
  let(:path) { 'path' }

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
          expect { subject }.to raise_error(error)
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
end
