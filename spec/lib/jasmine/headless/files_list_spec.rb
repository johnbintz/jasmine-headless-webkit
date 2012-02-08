require 'spec_helper'
require 'fakefs/spec_helpers'
require 'coffee-script'

describe Jasmine::Headless::FilesList do
  let(:files_list) { described_class.new }

  describe '#initialize' do
    before do
      described_class.any_instance.stubs(:load_initial_assets)
    end

    describe '#spec_file_line_numbers' do
      include FakeFS::SpecHelpers

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
      let(:files_list) { described_class.new(:config => config) }

      let(:config) { {
        'src_dir' => src_dir,
        'spec_dir' => spec_dir,
        'asset_paths' => asset_paths
      } }

      let(:src_dir) { 'src dir' }
      let(:spec_dir) { 'spec dir' }
      let(:asset_paths) { [] }
      let(:path) { 'path' }

      before do
        Jasmine::Headless::FilesList.stubs(:asset_paths).returns([])
      end

      let(:vendor_path) { Jasmine::Headless.root.join('vendor/assets/javascripts').to_s }

      context 'no vendored gem paths' do
        it 'should take the src dir and spec dirs' do
          files_list.search_paths.should == [ Jasmine::Core.path, vendor_path, File.expand_path(src_dir), File.expand_path(spec_dir) ]
        end
      end

      context 'vendored gem paths' do
        before do
          Jasmine::Headless::FilesList.stubs(:asset_paths).returns([ path ])
        end

        it 'should add the vendor gem paths to the list' do
          files_list.search_paths.should == [ Jasmine::Core.path, vendor_path, path, File.expand_path(src_dir), File.expand_path(spec_dir) ]
        end
      end

      context 'multiple dirs' do
        let(:dir_1) { 'dir 1' }
        let(:dir_2) { 'dir 2' }

        context 'src_dir is an array' do
          let(:src_dir) { [ dir_1, dir_2 ] }

          it 'should take the src dir and spec dirs' do
            files_list.search_paths.should == [ Jasmine::Core.path, vendor_path, File.expand_path(dir_1), File.expand_path(dir_2), File.expand_path(spec_dir) ]
          end
        end

        context 'asset_paths has entries' do
          let(:src_dir) { dir_1 }
          let(:asset_paths) { [ dir_2 ] }

          it 'should take the src dir and spec dirs' do
            files_list.search_paths.should == [ Jasmine::Core.path, vendor_path, File.expand_path(dir_1), File.expand_path(dir_2), File.expand_path(spec_dir) ]
          end
        end
      end
    end

    describe '#files' do
      let(:path_one) { 'one' }
      let(:path_two) { 'two' }
      let(:path_three) { 'three' }

      let(:file_one) { stub(:to_a => [ asset_one, asset_two ] ) }
      let(:file_two) { stub(:to_a => [ asset_two, asset_three ] ) }

      let(:asset_one) { stub(:pathname => Pathname(path_one), :to_ary => nil) }
      let(:asset_two) { stub(:pathname => Pathname(path_two), :to_ary => nil) }
      let(:asset_three) { stub(:pathname => Pathname(path_three), :to_ary => nil) }

      before do
        files_list.stubs(:required_files).returns(Jasmine::Headless::UniqueAssetList.new([ file_one, file_two ]))
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

    describe '#add_files' do
      let(:files_list) { described_class.new(:seed => 100) }

      let(:dir) { 'tmp' }

      before do
        FileUtils.mkdir_p dir

        10.times do |index|
          File.open(File.join(dir, "file-#{index}.js"), 'wb')
        end

        File.open(File.join(dir, 'file.js.erb'), 'wb')
      end

      before do
        files_list.send(:add_files, [ '*' ], 'spec_files', [ dir ])
      end

      it 'should load spec files in a random order' do
        files_list.files.collect { |name| name[%r{\d+}] }.should == %w{6 7 1 0 5 3 4 8 2 9}

        FileUtils.rm_rf dir
      end

      it 'should not load an excluded format' do
        files_list.files.any? { |file| file['.erb'] }.should be_false
      end
    end
  end
end

