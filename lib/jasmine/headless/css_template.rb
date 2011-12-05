require 'tilt/template'

module Jasmine::Headless
  class CSSTemplate < Tilt::Template
    include Jasmine::Headless::FileChecker
    self.default_mime_type = 'text/css'

    def prepare ; end

    def evaluate(scope, locals, &block)
      if bad_format?(file)
        alert_bad_format(file)
        return ''
      end
      file ? %{<link rel="stylesheet" href="#{file}" type="text/css" />} : data
    end
  end
end

