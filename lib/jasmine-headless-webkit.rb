module Jasmine
  autoload :FilesList, 'jasmine/files_list'
end

require 'jasmine/headless'
require 'jasmine/headless/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

