require 'spec_helper'

describe Jasmine::Headless::SpecFileAnalyzer do
  include FakeFS::SpecHelpers

  let(:file) { 'file' }
  let(:analyzer) { described_class.new(file) }

  describe '#action' do
    let(:line_numbers) do
      analyzer.action
    end

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
      "PR.registerLangHandler(PR.createSimpleLexer([[\"com\",/^#[^\\n\\r]*/,null,\"#\"],[\"pln\",/^[\\t\\n\\r \\xa0]+/,null,\"\\t\\n\\r \xC2\\xa0\"],[\"str\",/^\"(?:[^\"\\\\]|\\\\[\\S\\s])*(?:\"|$)/,null,'\"']],[[\"kwd\",/^(?:ADS|AD|AUG|BZF|BZMF|CAE|CAF|CA|CCS|COM|CS|DAS|DCA|DCOM|DCS|DDOUBL|DIM|DOUBLE|DTCB|DTCF|DV|DXCH|EDRUPT|EXTEND|INCR|INDEX|NDX|INHINT|LXCH|MASK|MSK|MP|MSU|NOOP|OVSK|QXCH|RAND|READ|RELINT|RESUME|RETURN|ROR|RXOR|SQUARE|SU|TCR|TCAA|OVSK|TCF|TC|TS|WAND|WOR|WRITE|XCH|XLQ|XXALQ|ZL|ZQ|ADD|ADZ|SUB|SUZ|MPY|MPR|MPZ|DVP|COM|ABS|CLA|CLZ|LDQ|STO|STQ|ALS|LLS|LRS|TRA|TSQ|TMI|TOV|AXT|TIX|DLY|INP|OUT)\\s/,\n"
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
end

