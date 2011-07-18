require 'spec_helper'
require 'qt/qmake'
require 'rbconfig'

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

      it { should == "qmake -spec linux-g++" }
    end

    context 'mac os x' do
      let(:platform) { :mac_os_x }

      it { should == "qmake -spec macx-g++" }
    end
  end

  describe '.qt_47_or_better?' do
    subject { described_class }

    before do
      Qt::Qmake.stubs(:qt_version).returns(version)
    end
    
    context 'no version' do
      let(:version) { nil }

      it { should_not be_qt_47_or_better }
    end

    context 'not better' do
      let(:version) { '4.6.0' }

      it { should_not be_qt_47_or_better }
    end

    context 'better' do
      let(:version) { '4.7.0' }

      it { should be_qt_47_or_better }
    end
  end
end

