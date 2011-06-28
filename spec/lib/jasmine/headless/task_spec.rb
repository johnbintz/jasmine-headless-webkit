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
    Jasmine::Headless::Task.new('jasmine:headless') do |t|
    end
  end
end
