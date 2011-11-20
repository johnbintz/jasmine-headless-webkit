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

    context 'with tilt template' do
      include FakeFS::SpecHelpers

      let(:content) { 'content' }

      before do
        File.open(path, 'wb') { |fh| fh.print content }
      end

      let(:klass) do
        Class.new(Tilt::Template) do
          def prepare ; end

          def evaluate(scope, locals, &block)
            "#{file} made it #{data}"
          end
        end
      end

      let(:other_klass) do
        Class.new(Tilt::Template) do
          def prepare ; end

          def evaluate(scope, locals, &block)
            data
          end
        end
      end

      before do
        Sprockets.stubs(:engines).with('.tilt').returns(klass)
        Sprockets.stubs(:engines).with('.jst').returns(other_klass)
      end

      context '.tilt' do
        let(:path) { 'path.tilt' }

        it { should == %{#{path} made it #{content}} }
      end

      context '.tilt.tilt' do
        let(:path) { 'path.tilt.tilt' }

        it { should == %{path.tilt made it #{path} made it #{content}} }
      end

      context '.jst.tilt' do
        let(:path) { 'path.jst.tilt' }

        it { should == %{<script type="text/javascript">#{path} made it #{content}</script>} }
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
