require 'spec_helper'

describe Jasmine::Headless::RequiredFile do
  let(:source_root) { File.expand_path('source_root') }
  let(:path) { File.join(source_root, 'path.js') }

  let(:file) { described_class.new(path, source_root, files_list) }

  let(:paths) { [ source_root ] }
  let(:path_searcher) { stub }
  let(:files_list) { stub(:path_searcher => path_searcher) }

  subject { file }

  its(:path) { should == path }
  its(:source_root) { should == source_root }
  its(:parent) { should == files_list }

  describe '#has_dependencies?' do
    it 'should have dependencies' do
      file.instance_variable_set(:@dependencies, [ 1 ])

      file.should have_dependencies
    end

    it 'should not have dependencies' do
      file.instance_variable_set(:@dependencies, [])

      file.should_not have_dependencies
    end
  end

  describe '#includes?' do
    it 'includes itself' do
      file.includes?(path).should be_true
    end

    context 'with dependencies' do
      let(:other_file) { stub }
      let(:other_path) { 'other path' }
      let(:third_path) { 'third path' }

      before do
        other_file.stubs(:includes?).with(other_path).returns(true)
        other_file.stubs(:includes?).with(third_path).returns(false)

        file.stubs(:dependencies).returns([ other_file ])
      end

      it 'checks dependencies' do
        file.includes?(third_path).should be_false
        file.includes?(other_path).should be_true
      end
    end
  end

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

    let(:directive) { 'require' }

    let(:dirname) { 'subdir/subsubdir' }
    let(:dir) { File.join(source_root, dirname) }

    let(:path) { path_file }
    let(:path_file) { File.join(dir, 'path.js') }
    let(:req_file) { File.join(dir, "req.js") }
    let(:other_file) { File.join(dir, "other.js") }

    let(:content) { "//= #{directive} '#{req_name}'\njavascript" }

    before do
      FileUtils.mkdir_p dir
      File.open(path_file, 'wb') { |fh| fh.print content }
      File.open(req_file, 'wb')
      File.open(other_file, 'wb')
    end

    subject { file.dependencies }

    context 'absolute' do
      context 'require' do
        context 'file exists' do
          let(:req_name) { File.join(dirname, 'req') }

          before do
            path_searcher.expects(:find).with(File.join(dirname, 'req')).returns([ req_file, source_root ])
          end

          it { should == [ described_class.new(req_file, source_root, file) ] }
        end

        context 'file does not exist' do
          let(:req_name) { File.join(dirname, 'bad') }

          before do
            path_searcher.expects(:find).with(File.join(dirname, 'bad')).returns(false)
          end

          it 'should raise an exception' do
            expect { subject }.to raise_error(Sprockets::FileNotFound)
          end
        end
      end
    end

    context 'relative' do
      context 'require' do
        context 'file exists' do
          let(:req_name) { './req' }

          before do
            path_searcher.expects(:find).with(File.join(dirname, 'req')).returns([ req_file, source_root ])
          end

          it { should == [ described_class.new(req_file, source_root, file) ] }
        end

        context 'file does not exist' do
          let(:req_name) { './bad' }

          before do
            path_searcher.expects(:find).with(File.join(dirname, 'bad')).returns(false)
          end

          it 'should raise an exception' do
            expect { subject }.to raise_error(Sprockets::FileNotFound)
          end
        end
      end
    end

    context 'require_self' do
      subject { file.file_paths }

      let(:content) do
        <<-ENDTXT
//= require #{dirname}/req
//= require_self
//= require #{dirname}/other
ENDTXT
      end

      before do
        path_searcher.expects(:find).with(File.join(dirname, 'req')).returns([ req_file, source_root ])
        path_searcher.expects(:find).with(File.join(dirname, 'other')).returns([ other_file, source_root ])
      end

      it { should == [
        req_file,
        path_file,
        other_file
      ] }
    end
  end

  describe '#file_paths' do
    let(:other_path) { File.join(source_root, 'other_path.js') }
    let(:other_file) { described_class.new(other_path, source_root, file) }

    before do
      file.stubs(:dependencies).returns([ other_file ])
      other_file.stubs(:dependencies).returns([])
    end

    it 'should flatten all the paths in itself and descendents' do
      file.file_paths.should == [ other_path, path ]
    end
  end
end

