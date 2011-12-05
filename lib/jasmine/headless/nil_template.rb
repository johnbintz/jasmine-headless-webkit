require 'tilt/template'
require 'rainbow'

module Jasmine::Headless
  class NilTemplate < Tilt::Template
    
    def prepare ; end

    def evaluate(scope, locals, &block)
      return ''
    end
  end
end

