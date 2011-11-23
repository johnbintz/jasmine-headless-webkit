require 'jasmine/headless'
require 'jasmine/headless/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

module Digest
  autoload :JasmineTest, 'digest/jasmine_test'
end

