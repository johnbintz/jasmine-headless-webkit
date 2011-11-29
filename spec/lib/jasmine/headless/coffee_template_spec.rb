require 'spec_helper'

describe Jasmine::Headless::CoffeeTemplate do
  let(:data) { 'data' }
  let(:path) { 'path.coffee' }

  let(:template) { described_class.new(path) { data } }

  subject { template.render }

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

