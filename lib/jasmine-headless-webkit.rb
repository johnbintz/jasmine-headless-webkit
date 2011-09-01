module Jasmine
  module Headless
    autoload :CoffeeScriptCache, 'jasmine/headless/coffee_script_cache'
  end
end

require 'jasmine/headless/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

