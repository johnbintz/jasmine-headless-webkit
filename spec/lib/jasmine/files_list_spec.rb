require 'spec_helper'
require 'jasmine/files_list'
require 'fakefs/spec_helpers'
require 'coffee-script'

describe Jasmine::FilesList do
  let(:files_list) { Jasmine::FilesList.new }

  describe '#initialize' do
    it "should have default files" do
      files_list.files.should == [
        File.join(Jasmine.root, "lib/jasmine.js"),
        File.join(Jasmine.root, "lib/jasmine-html.js"),
        File.expand_path('jasmine/jasmine.headless-reporter.js')
      ]
    end
  end

  describe '#use_config' do
    let(:files_list) { Jasmine::FilesList.new(:config => config) }

    include FakeFS::SpecHelpers

    let(:src_dir) { 'src' }
    let(:spec_dir) { 'spec' }

    let(:first_file) { File.join(src_dir, 'js/first_file.js') }
    let(:src_file) { File.join(src_dir, 'js/src_file.js') }
    let(:spec_file) { File.join(spec_dir, 'spec_file_spec.js') }
    let(:helper_file) { File.join(spec_dir, 'helper/helper_file.js') }
    let(:stylesheet_file) { File.join(src_dir, 'stylesheet/blah.css') }

    before do
      [ first_file, src_file, spec_file, helper_file, stylesheet_file ].each do |file|
        File.open(file, 'w')
      end
    end

    let(:config) { {
      'src_dir' => src_dir,
      'spec_dir' => spec_dir,
      'src_files' => [ 'js/first_file.js', 'js/*.js' ],
      'spec_files' => [ '*_spec.js' ],
      'helpers' => [ 'helper/*.js' ],
      'stylesheets' => [ 'stylesheet/*.css' ]
    } }

    it 'should read the data from the jasmine.yml file and add the files' do
      files_list.files.should == Jasmine::FilesList::DEFAULT_FILES + [
        File.expand_path(first_file),
        File.expand_path(src_file),
        File.expand_path(stylesheet_file),
        File.expand_path(helper_file),
        File.expand_path(spec_file)
      ]
    end
  end

  describe '#use_spec?' do
    let(:spec_file) { 'my/spec.js' }

    let(:files_list) { Jasmine::FilesList.new(:only => filter) }

    context 'no filter provided' do
      let(:filter) { [] }

      it "should allow the spec" do
        files_list.use_spec?(spec_file).should be_true
      end
    end

    context 'filter provided' do
      let(:filter) { [ spec_file ] }

      it "should use the spec" do
        files_list.use_spec?(spec_file).should be_true
      end

      it "should not use the spec" do
        files_list.use_spec?('other/file').should be_false
      end
    end
  end

  context 'with filtered specs' do
    let(:files_list) { Jasmine::FilesList.new(:only => filter, :config => config) }
    let(:spec_dir) { 'spec' }

    include FakeFS::SpecHelpers

    let(:config) { {
      'spec_files' => [ '*_spec.js' ],
      'spec_dir' => spec_dir
    } }

    before do
      %w{one_spec.js two_spec.js}.each do |file|
        File.open(File.join(spec_dir, file), 'w')
      end
    end

    let(:filter) { 'spec/one_spec.js' }

    it 'should return all files for files' do
      files_list.files.any? { |file| file['two_spec.js'] }.should be_true
      files_list.filtered?.should be_true
    end

    it 'should return only filtered files for filtered_files' do
      files_list.filtered_files.any? { |file| file['two_spec.js'] }.should be_false
    end
  end

  describe '#.*files_to_html' do
    include FakeFS::SpecHelpers

    context 'one coffeescript file' do
      before do
        files_list.instance_variable_set(:@files, [
                                         'test.js',
                                         'test.coffee',
                                         'test.css'
        ])

        files_list.instance_variable_set(:@filtered_files, [
                                         'test.js',
                                         'test.coffee'
        ])

        File.open('test.coffee', 'w') { |fh| fh.print "first" }

        CoffeeScript.stubs(:compile).with() { |field| field.read == "first\n" }.returns("i compiled")
      end

      context '#files_to_html' do
        it "should create the right HTML" do
          files_list.files_to_html.should == [
            %{<script type="text/javascript" src="test.js"></script>},
            %{<script type="text/javascript">i compiled</script>},
            %{<link rel="stylesheet" href="test.css" type="text/css" />}
          ]
        end
      end

      context '#filtered_files_to_html' do
        it "should create the right HTML" do
          files_list.filtered_files_to_html.should == [
            %{<script type="text/javascript" src="test.js"></script>},
            %{<script type="text/javascript">i compiled</script>}
          ]
        end
      end
    end

    context 'two coffeescript files' do
      before do
        files_list.instance_variable_set(:@files, [
                                         'test.js',
                                         'test.coffee',
                                         'test2.coffee',
                                         'test.css'
        ])

        files_list.instance_variable_set(:@filtered_files, [
                                         'test.js',
                                         'test.coffee'
        ])

        File.open('test.coffee', 'w') { |fh| fh.print "first" }
        File.open('test2.coffee', 'w') { |fh| fh.print "second" }
      end

      context '#files_to_html' do
        it "should create the right HTML" do
          CoffeeScript.stubs(:compile).with() { |field| field.read == "first\nsecond\n" }.returns("i compiled")

          files_list.files_to_html.should == [
            %{<script type="text/javascript" src="test.js"></script>},
            %{<script type="text/javascript">i compiled</script>},
            %{<link rel="stylesheet" href="test.css" type="text/css" />}
          ]
        end
      end

      context '#filtered_files_to_html' do
        it "should create the right HTML" do
          CoffeeScript.stubs(:compile).with() { |field| field.read == "first\n" }.returns("i compiled")

          files_list.filtered_files_to_html.should == [
            %{<script type="text/javascript" src="test.js"></script>},
            %{<script type="text/javascript">i compiled</script>}
          ]
        end
      end
    end
  end
end

