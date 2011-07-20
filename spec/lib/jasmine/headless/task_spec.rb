require 'spec_helper'
require 'fakefs/spec_helpers'
require 'jasmine/headless/task'
require 'mocha'

describe Jasmine::Headless::Task do
  before do
    Jasmine::Headless::Task.any_instance.stubs(:desc)
    Jasmine::Headless::Task.any_instance.stubs(:task)
  end

  after do
    Object.send(:remove_const, :Rails) if defined?(Rails)
  end

  describe 'define task' do
    context 'without Rails' do
      it 'should not explode when Rails is undefined' do
        Jasmine::Headless::Task.new('jasmine:headless')
      end
    end

    context 'with Rails' do
      context 'without version' do
        before do
          module Rails
            def self.version
              return "0"
            end
          end
        end

        it 'should be OK if rails is defined' do
          Jasmine::Headless::Task.new('jasmine:headless')
        end
      end

      context 'with version' do
        before do
          module Rails
            def self.version
              return "0"
            end
          end
        end

        it 'should be OK if rails is defined' do
          Jasmine::Headless::Task.new('jasmine:headless')
        end
      end
    end
  end

  describe 'jasmine:headless integration test' do
    context 'with successful test' do
      let(:test) do
        described_class.new do |t|
          t.jasmine_config = "spec/jasmine/success/success.yml"
        end
      end

      it 'should do nothing on success' do
        expect { test.send(:run_rake_task) }.to_not raise_error
      end
    end

    context 'with failing test' do
      let(:test) do
        described_class.new do |t|
          t.jasmine_config = "spec/jasmine/failure/failure.yml"
        end
      end

      it 'should raise an exception on failure' do
        expect { test.send(:run_rake_task) }.to raise_error(Jasmine::Headless::TestFailure)
      end
    end

    context 'with console.log using test' do
      let(:test) do
        described_class.new do |t|
          t.jasmine_config = "spec/jasmine/console_log/console_log.yml"
        end
      end

      it 'should raise an exception on console.log usage' do
        expect { test.send(:run_rake_task) }.to raise_error(Jasmine::Headless::ConsoleLogUsage)
      end
    end
  end
end

