module Jasmine
  module Headless
    autoload :CoffeeScriptCache, 'jasmine/headless/coffee_script_cache'
    autoload :SpecFileAnalyzer, 'jasmine/headless/spec_file_analyzer'
    autoload :CacheableAction, 'jasmine/headless/cacheable_action'
  end
end

require 'jasmine/headless/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

