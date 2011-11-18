require 'spec_helper'

describe Jasmine::Headless::SpecFileAnalyzer do

  let(:file) { 'file' }
  let(:analyzer) { described_class.new(file) }

  describe '#action' do
    let(:line_numbers) do
      analyzer.action
    end

    context 'fake files' do
      include FakeFS::SpecHelpers

      before do
        File.open(file, 'wb') { |fh| fh.print file_data }
      end

      context 'coffeescript' do
        let(:file_data) do
          <<-SPEC
  describe 'test', ->
    context 'yes', ->
      it 'should do something', ->
        "yes"
  SPEC
        end

        it 'should get the line numbers' do
          line_numbers['test'].should == [ 1 ]
          line_numbers['yes'].should == [ 2 ]
          line_numbers['should do something'].should == [ 3 ]
        end
      end

      context 'javascript' do
        let(:file_data) do
          <<-SPEC
  describe('test', function() {
    context('yes', function() {
      it('should do something', function() {

      });
    });
  });
  SPEC
        end

        it 'should get the line numbers' do
          line_numbers['test'].should == [ 1 ]
          line_numbers['yes'].should == [ 2 ]
          line_numbers['should do something'].should == [ 3 ]
        end
      end
    end

    context 'utf 8' do
      let(:analyzer) { described_class.new('spec/files/UTF-8-test.txt') }
      let(:file_data) { '' }

      it 'should not explode' do
        line_numbers
      end
    end
  end
end

