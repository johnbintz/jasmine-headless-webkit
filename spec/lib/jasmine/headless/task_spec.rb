require 'spec_helper'
require 'fakefs/spec_helpers'
require 'jasmine/headless/task'

module Jasmine
  module Headless
    class Task
      def desc(block); end
      def task(block); end
    end
  end
end

describe Jasmine::Headless::Task do
  after do
    Object.send(:remove_const, :Rails) if defined?(Rails)
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

