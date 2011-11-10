require 'spec_helper'
require 'qt/qmake'
require 'rbconfig'
require 'rubygems/version'

describe Qt::Qmake do
  describe '.make_installed?' do
    subject { described_class }

    before do
      Qt::Qmake.stubs(:make_path).returns(path)
    end

    context 'not installed' do
      let(:path) { nil }

      it { should_not be_make_installed }
    end

    context 'installed' do
      let(:path) { '/here/there/make' }

      it { should be_make_installed }
    end
  end

  describe '.installed?' do
    subject { described_class }

    before do
      Qt::Qmake.stubs(:path).returns(path) 
    end

    context 'not installed' do
      let(:path) { nil }

      it { should_not be_installed }
    end

    context 'installed' do
      let(:path) { '/here/there/qmake' }

      it { should be_installed }
    end
  end

  describe '.command' do
    subject { described_class.command }

    before do
      Qt::Qmake.stubs(:platform).returns(platform)
      Qt::Qmake.stubs(:path).returns("qmake")
    end

    context 'linux' do
      let(:platform) { :linux }

      it { should =~ /^qmake/ }
      it { should =~ /-spec linux-g\+\+$/ }
    end

    context 'mac os x' do
      let(:platform) { :mac_os_x }

      it { should =~ /^qmake/ }
      it { should =~ /-spec macx-g\+\+$/ }
    end
  end

  describe '.best_qmake' do
    before do
      Qt::Qmake.stubs(:get_exe_path).with('qmake-qt4').returns(path_one)
      Qt::Qmake.stubs(:get_exe_path).with('qmake').returns(path_two)

      Qt::Qmake.stubs(:qt_version_of).with(path_one).returns(Gem::Version.create(version_one))
      Qt::Qmake.stubs(:qt_version_of).with(path_two).returns(Gem::Version.create(version_two))
    end

    subject { described_class.best_qmake }

    let(:path_one) { nil }
    let(:path_two) { nil }
    let(:version_one) { nil }
    let(:version_two) { nil }

    context 'nothing found' do
      it { should be_nil }
    end

    context 'one found' do
      let(:path_one) { 'one' }

      context 'not good' do
        let(:version_one) { '4.5' }

        it { should be_nil }
      end

      context 'good' do
        let(:version_one) { '4.7' }

        it { should == path_one }
      end
    end

    context 'two found' do
      let(:path_one) { 'one' }
      let(:path_two) { 'two' }

      context 'neither good' do
        let(:version_one) { '4.5' }
        let(:version_two) { '4.5' }

        it { should be_nil }
      end

      context 'one good' do
        let(:version_one) { '4.7' }
        let(:version_two) { '4.5' }

        it { should == path_one }
      end

      context 'both good' do
        context 'one better' do
          let(:version_one) { '4.7' }
          let(:version_two) { '4.8' }

          it { should == path_two }
        end

        context 'both same' do
          let(:version_one) { '4.7' }
          let(:version_two) { '4.7' }

          it { should == path_one }
        end
      end
    end
  end
end

