module Jasmine
  module Headless
    module Webkit
    end
  end
end

require 'jasmine/headless/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

