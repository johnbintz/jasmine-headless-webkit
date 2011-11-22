require 'tilt/template'

module Jasmine::Headless
  class CSSTemplate < Tilt::Template
    self.default_mime_type = 'text/css'

    def prepare ; end

    def evaluate(scope, locals, &block)
      file ? %{<link rel="stylesheet" href="#{file}" type="text/css" />} : data
    end
  end
end

