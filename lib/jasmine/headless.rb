require 'pathname'

module Jasmine
  module Headless
    
    EXCLUDED_FORMATS = %w{less sass scss erb str}
    
    autoload :CommandLine, 'jasmine/headless/command_line'

    autoload :CoffeeScriptCache, 'jasmine/headless/coffee_script_cache'
    autoload :SpecFileAnalyzer, 'jasmine/headless/spec_file_analyzer'
    autoload :CacheableAction, 'jasmine/headless/cacheable_action'
    autoload :VERSION, 'jasmine/headless/version'
    autoload :Runner, 'jasmine/headless/runner'
    autoload :Options, 'jasmine/headless/options'
    autoload :Task, 'jasmine/headless/task'

    autoload :FilesList, 'jasmine/headless/files_list'
    autoload :UniqueAssetList, 'jasmine/headless/unique_asset_list'

    autoload :TemplateWriter, 'jasmine/headless/template_writer'
    
    autoload :FileChecker, 'jasmine/headless/file_checker'

    autoload :CoffeeTemplate, 'jasmine/headless/coffee_template'
    autoload :JSTemplate, 'jasmine/headless/js_template'
    autoload :JSTTemplate, 'jasmine/headless/jst_template'
    autoload :CSSTemplate, 'jasmine/headless/css_template'
    autoload :NilTemplate, 'jasmine/headless/nil_template'

    autoload :Report, 'jasmine/headless/report'
    autoload :ReportMessage, 'jasmine/headless/report_message'

    class << self
      def root
        @root ||= Pathname(File.expand_path('../../..', __FILE__))
      end

      def warn(message)
        output.puts message if show_warnings?
      end

      def show_warnings=(show)
        @show_warnings = show
      end

      def show_warnings?
        @show_warnings = true if @show_warnings.nil?

        @show_warnings
      end

      def output
        $stdout
      end
    end
  end
end

require 'jasmine/headless/errors'

