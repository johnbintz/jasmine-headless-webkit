require 'tilt/template'
require 'rainbow'

module Jasmine::Headless
  # This template flattens .coffee.erb files that may be present on
  # the Rails asset pipeline. The file is rendered as CoffeeScript;
  # erb template will not be rendered. 
  class CoffeeErbTemplate < Tilt::Template

    def prepare ; end

    def evaluate(scope, locals, &block)
      if file[/coffee.erb$/]
        Jasmine::Headless.warn("[%s] %s: %s" % [ "Erb File".color(:magenta), file.color(:yellow), "flatten template".color(:white) ])
      end
      return ''
    end
  end
end

