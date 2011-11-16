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

      it { should == %{<script type="text/javascript" src="#{path}"></script>} }
    end

    context '.coffee' do
      let(:path) { 'path.coffee' }

      let(:handle_expectation) { Jasmine::Headless::CoffeeScriptCache.any_instance.stubs(:handle) }

      context 'compilation error' do
        let(:error) { CoffeeScript::CompilationError.new("fail") }

        before do
          handle_exception.raises(error)
        end

        it 'should pass along the error' do
          expect { subject }.to raise_error(error)
        end
      end

      context 'compiles fine' do
        let(:cached_expectation) { Jasmine::Headless::CoffeeScriptCache.any_instance.stubs(:cached?).returns(cache_return) }

        before do

        end
      end
    end
  end
end
