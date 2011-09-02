module Jasmine
  autoload :FilesList, 'jasmine/files_list'
  autoload :TemplateWriter, 'jasmine/template_writer'

  module Headless
    autoload :CoffeeScriptCache, 'jasmine/headless/coffee_script_cache'
    autoload :SpecFileAnalyzer, 'jasmine/headless/spec_file_analyzer'
    autoload :CacheableAction, 'jasmine/headless/cacheable_action'
    autoload :VERSION, 'jasmine/headless/version'
    autoload :Runner, 'jasmine/headless/runner'
    autoload :Options, 'jasmine/headless/options'
    autoload :Task, 'jasmine/headless/task'

    autoload :Report, 'jasmine/headless/report'
    autoload :ReportMessage, 'jasmine/headless/report_message'
  end
end

require 'jasmine/headless/errors'

require 'jasmine/headless/railtie' if defined?(Rails) && Rails::VERSION::MAJOR >= 3

