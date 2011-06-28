require 'spec_helper'
require 'fakefs/spec_helpers'
require 'jasmine/headless/task'
require 'mocha'

describe Jasmine::Headless::Task do
  after do
    Object.send(:remove_const, :Rails) if defined?(Rails)
  end

  describe 'define task' do
    before do
      Jasmine::Headless::Task.any_instance.stubs(:desc)
      Jasmine::Headless::Task.any_instance.stubs(:task)
    end

    context 'without Rails' do
      it 'should not explode when Rails is undefined' do
        Jasmine::Headless::Task.new('jasmine:headless')
      end
    end

    context 'with Rails' do
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

