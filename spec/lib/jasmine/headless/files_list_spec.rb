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

  def self.no_default_files!
    before do
      described_class.stubs(:default_files).returns([])
    end
  end

  it 'should have tests for #use_config!'
  it 'should have tests for #add_files'

  describe '#spec_file_line_numbers' do
    include FakeFS::SpecHelpers

    no_default_files!

    before do
      files_list.stubs(:spec_files).returns(['test.coffee', 'test2.coffee'])

      File.open('test.coffee', 'w') { |fh| fh.print "describe('cat')\ndescribe('cat')" }
      File.open('test2.coffee', 'w') { |fh| fh.print "no matches" }
    end

    it 'should generate filenames and line number info' do
      files_list.spec_file_line_numbers.should == {
        'test.coffee' => { 'cat' => [ 1, 2 ] }
      }
    end
  end

  describe '#search_paths' do
    no_default_files!

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

  describe '#files' do
    let(:path_one) { 'one' }
    let(:path_two) { 'two' }
    let(:path_three) { 'three' }

    let(:file_one) { stub(:required_assets => [ asset_one, asset_two ] ) }
    let(:file_two) { stub(:required_assets => [ asset_two, asset_three ] ) }

    let(:asset_one) { stub(:pathname => Pathname(path_one)) }
    let(:asset_two) { stub(:pathname => Pathname(path_two)) }
    let(:asset_three) { stub(:pathname => Pathname(path_three)) }

    before do
      files_list.stubs(:required_files).returns([ file_one, file_two ])
    end

    subject { files_list.files }

    it { should == [ path_one, path_two, path_three ] }
  end

  describe '#filtered_files' do
    let(:spec_dir) { 'spec' }

    let(:file_one) { "#{spec_dir}/one" }
    let(:file_two) { "#{spec_dir}/two" }
    let(:file_three) { "#{spec_dir}/three" }
    let(:file_four) { 'other/four' }

    before do
      files_list.stubs(:files).returns([
        file_one,
        file_two,
        file_three,
        file_four
      ])

      files_list.stubs(:potential_files_to_filter).returns([ file_one, file_two, file_three ])
    end

    subject { files_list.filtered_files }

    context 'empty filter' do
      before do
        files_list.stubs(:spec_filter).returns([])
      end

      it { should == [ file_one, file_two, file_three, file_four ] }
    end

    context 'with filter' do
      before do
        files_list.stubs(:spec_filter).returns([ "#{spec_dir}/one", '**/tw*' ])
      end

      it { should == [ file_one, file_two, file_four ] }
    end
  end
end

