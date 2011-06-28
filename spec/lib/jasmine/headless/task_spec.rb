require 'spec_helper'
require 'fakefs/spec_helpers'
require 'jasmine/headless/task'

module Jasmine
  module Headless
    class Task
      def desc(block)
      end
      def task(block)
      end
    end
  end
end
describe Jasmine::Headless::Task do
  it 'should not explode when Rails is undefined' do
    Object.send(:remove_const, :Rails) if defined?(Rails)
    Jasmine::Headless::Task.new('jasmine:headless') do |t|
    end
  end
  it 'should be OK if rails is defined' do
    module Rails
      def self.version
        return "0"
      end
    end
    Jasmine::Headless::Task.new('jasmine:headless') do |t|
    end
  end
end
