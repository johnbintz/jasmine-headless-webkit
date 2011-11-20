# encoding: UTF-8

require 'spec_helper'
require 'fakefs/spec_helpers'
require 'coffee-script'

describe Jasmine::Headless::FilesList do
  let(:files_list) { described_class.new }

  describe '#initialize' do
    it "should have default files" do
      files_list.files.should == [
        File.join(Jasmine::Core.path, "jasmine.js"),
        File.join(Jasmine::Core.path, "jasmine-html.js"),
        File.join(Jasmine::Core.path, "jasmine.css"),
        File.expand_path('vendor/assets/javascripts/jasmine-extensions.js'),
        File.expand_path('vendor/assets/javascripts/intense.js'),
        File.expand_path('vendor/assets/javascripts/headless_reporter_result.js'),
        File.expand_path('vendor/assets/javascripts/jasmine.HeadlessConsoleReporter.js'),
        File.expand_path('vendor/assets/javascripts/jsDump.js'),
        File.expand_path('vendor/assets/javascripts/beautify-html.js'),
      ]
    end
  end

  describe '#use_config' do
    let(:files_list) { described_class.new(:config => config) }

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
        FileUtils.mkdir_p File.split(file).first
        File.open(file, 'w')
      end
    end

    shared_examples_for :reading_data do
      let(:expected_files) do
        [
          File.expand_path(first_file),
          File.expand_path(src_file),
          File.expand_path(stylesheet_file),
          File.expand_path(helper_file),
          File.expand_path(spec_file)
        ]
      end

      it 'should read the data from the jasmine.yml file and add the files' do
        files_list.files.should == expected_files

        files_list.spec_files.should == [ File.expand_path(spec_file) ]
      end
    end

    context 'with normal list' do
      let(:config) { {
        'src_dir' => src_dir,
        'spec_dir' => spec_dir,
        'src_files' => [ 'js/first_file.js', 'js/*.js' ],
        'spec_files' => [ '*_spec.js' ],
        'helpers' => [ 'helper/*.js' ],
        'stylesheets' => [ 'stylesheet/*.css' ]
      } }

      it_should_behave_like :reading_data
    end

    context 'with multidimensional list' do
      let(:config) { {
        'src_dir' => src_dir,
        'spec_dir' => spec_dir,
        'src_files' => [ [ 'js/first_file.js', 'js/*.js' ] ],
        'spec_files' => [ '*_spec.js' ],
        'helpers' => [ 'helper/*.js' ],
        'stylesheets' => [ 'stylesheet/*.css' ]
      } }

      it_should_behave_like :reading_data
    end

    context 'with multidimensional src dir' do
      let(:config) { {
        'src_dir' => [ src_dir ],
        'spec_dir' => spec_dir,
        'src_files' => [ [ 'js/first_file.js', 'js/*.js' ] ],
        'spec_files' => [ '*_spec.js' ],
        'helpers' => [ 'helper/*.js' ],
        'stylesheets' => [ 'stylesheet/*.css' ]
      } }

      it_should_behave_like :reading_data
    end
  end

  context 'with filtered specs' do
    let(:files_list) { Jasmine::Headless::FilesList.new(:only => filter, :config => config) }
    let(:spec_dir) { 'spec' }

    include FakeFS::SpecHelpers

    let(:config) { {
      'spec_files' => [ '*_spec.js' ],
      'spec_dir' => spec_dir
    } }

    let(:spec_files) { %w{one_spec.js two_spec.js whatever.js} }

    before do
      spec_files.each do |file|
        FileUtils.mkdir_p spec_dir
        File.open(File.join(spec_dir, file), 'w')
      end
    end

    context 'empty filter' do
      let(:filter) { [] }

      it 'should return all files for filtered and all files' do
        files_list.files.any? { |file| file['two_spec.js'] }.should be_true
        files_list.filtered?.should be_false
        files_list.should_not have_spec_outside_scope
        files_list.spec_files.sort.should == %w{one_spec.js two_spec.js}.sort.collect { |file| File.expand_path(File.join(spec_dir, file)) }
      end
    end

    context 'filter with a file that is matchable' do
      let(:filter) { [ File.expand_path('spec/one_spec.js') ] }

      it 'should return all files for files' do
        files_list.files.any? { |file| file['two_spec.js'] }.should be_true
        files_list.filtered?.should be_true
        files_list.should_not have_spec_outside_scope
        files_list.spec_files.should == filter
      end

      it 'should return only filtered files for filtered_files' do
        files_list.filtered_files.any? { |file| file['two_spec.js'] }.should be_false
        files_list.should_not have_spec_outside_scope
      end
    end

    context 'filter with a glob' do
      let(:filter) { [ File.expand_path('spec/one*') ] }

      it 'should return all files for files' do
        files_list.files.any? { |file| file['two_spec.js'] }.should be_true
        files_list.filtered?.should be_true
        files_list.should_not have_spec_outside_scope
      end

      it 'should return only filtered files for filtered_files' do
        files_list.filtered_files.any? { |file| file['two_spec.js'] }.should be_false
        files_list.should_not have_spec_outside_scope
      end
    end

    context 'filter with a file that is not even there' do
      let(:filter) { [ File.expand_path('spec/whatever.js') ] }

      it 'should use the provided file' do
        files_list.filtered_files.any? { |file| file['whatever.js'] }.should be_true
        files_list.should have_spec_outside_scope
      end
    end
  end

  describe '#spec_file_line_numbers' do
    include FakeFS::SpecHelpers

    before do
      files_list.instance_variable_set(:@spec_files, [
                                       'test.coffee',
                                       'test2.coffee'
      ])

      File.open('test.coffee', 'w') { |fh| fh.print "describe('cat')\ndescribe('cat')" }
      File.open('test2.coffee', 'w') { |fh| fh.print "no matches" }
    end

    it 'should generate filenames and line number info' do
      files_list.spec_file_line_numbers.should == {
        'test.coffee' => { 'cat' => [ 1, 2 ] }
      }
    end
  end

  describe '#add_dependency' do
    let(:file) { 'file' }
    let(:other_file) { 'other' }
    let(:path) { 'path' }

    before do
      files_list.stubs(:find_dependency).with(file).returns(path)
      files_list.stubs(:find_dependency).with(other_file).returns(false)
    end

    context 'not found' do
      before do
        files_list.expects(:add_file).never
      end

      it 'should do nothing' do
        files_list.add_dependency('', other_file, nil)
      end
    end

    context 'require' do
      before do
        files_list.expects(:add_file).with(path, nil)
      end

      it 'should add the file to the front' do
        files_list.add_dependency('require', file, nil)
      end
    end

    context 'require_tree' do
      include FakeFS::SpecHelpers

      let(:paths) { %w{one.js dir/two.coffee dir/three.css dir/subdir/four.js.erb other/five.css.erb} }

      before do
        paths.each do |path|
          FileUtils.mkdir_p File.dirname(path)
          File.open(path, 'wb')

          if path[%r{\.(js|css|coffee)$}]
            files_list.expects(:find_dependency).with(path).returns(other_file)
            files_list.expects(:add_file).with(other_file, nil)
          end
        end
      end

      it 'should add the file to the front' do
        files_list.add_dependency('require_tree', '.', File.expand_path('.'))
      end
    end
  end

  describe '#search_paths' do
    let(:files_list) { described_class.new(:config => config) }

    let(:config) { {
      'src_dir' => src_dir,
      'spec_dir' => spec_dir
    } }

    let(:src_dir) { 'src dir' }
    let(:spec_dir) { 'spec dir' }
    let(:path) { 'path' }

    before do
      Jasmine::Headless::FilesList.stubs(:vendor_asset_paths).returns([])
    end

    context 'no vendored gem paths' do
      it 'should take the src dir and spec dirs' do
        files_list.search_paths.should == [ Jasmine::Core.path, File.expand_path(src_dir), File.expand_path(spec_dir) ]
      end
    end

    context 'vendored gem paths' do
      before do
        Jasmine::Headless::FilesList.stubs(:vendor_asset_paths).returns([ path ])
      end

      it 'should add the vendor gem paths to the list' do
        files_list.search_paths.should == [ Jasmine::Core.path, File.expand_path(src_dir), File.expand_path(spec_dir), path ]
      end
    end

    context 'src_dir is an array' do
      let(:dir_1) { 'dir 1' }
      let(:dir_2) { 'dir 2' }

      let(:src_dir) { [ dir_1, dir_2 ] }

      it 'should take the src dir and spec dirs' do
        files_list.search_paths.should == [ Jasmine::Core.path, File.expand_path(dir_1), File.expand_path(dir_2), File.expand_path(spec_dir) ]
      end
    end
  end

  describe '.vendor_asset_paths' do
    include FakeFS::SpecHelpers

    let(:dir_one) { 'dir_one' }
    let(:dir_two) { 'dir_two' }

    let(:gem_one) { stub(:gem_dir => dir_one) }
    let(:gem_two) { stub(:gem_dir => dir_two) }

    before do
      described_class.instance_variable_set(:@vendor_asset_paths, nil)

      FileUtils.mkdir_p File.join(dir_two, 'vendor/assets/javascripts')

      Gem::Specification.stubs(:_all).returns([gem_one, gem_two])
    end

    it 'should return all matching gems with vendor/assets/javascripts directories' do
      described_class.vendor_asset_paths.should == [ File.join(dir_two, 'vendor/assets/javascripts') ]
    end
  end

  describe '#find_dependency' do
    include FakeFS::SpecHelpers

    let(:dir) { File.expand_path('dir') }

    let(:filename) { 'file' }
    let(:file) { "#{filename}.js" }

    before do
      FileUtils.mkdir_p dir

      %w{file.sub.js file.js.coffee}.each do |file|
        File.open(File.join(dir, file), 'wb')
      end

      files_list.stubs(:search_paths).returns([ dir ])
    end

    subject { files_list.find_dependency(search) }

    context 'bad' do
      let(:search) { 'bad' }

      it { should be_false }
    end

    context 'file' do
      let(:search) { 'file' }

      it { should == [ File.join(dir, 'file.js.coffee'), dir ] }
    end

    context 'file.sub' do
      let(:search) { 'file.sub' }

      it { should == [ File.join(dir, 'file.sub.js'), dir ] }
    end
  end
end

