require 'pathname'

module Jasmine::Headless
  autoload :CoffeeScriptCache, 'jasmine/headless/coffee_script_cache'
  autoload :SpecFileAnalyzer, 'jasmine/headless/spec_file_analyzer'
  autoload :CacheableAction, 'jasmine/headless/cacheable_action'
  autoload :VERSION, 'jasmine/headless/version'
  autoload :Runner, 'jasmine/headless/runner'
  autoload :Options, 'jasmine/headless/options'
  autoload :Task, 'jasmine/headless/task'
  autoload :FilesList, 'jasmine/headless/files_list'
  autoload :TestFile, 'jasmine/headless/test_file'

  autoload :TemplateWriter, 'jasmine/headless/template_writer'

  autoload :Report, 'jasmine/headless/report'
  autoload :ReportMessage, 'jasmine/headless/report_message'

  class << self
    def root
      @root ||= Pathname(File.expand_path('../../..', __FILE__))
    end
  end
end

require 'jasmine/headless/errors'
