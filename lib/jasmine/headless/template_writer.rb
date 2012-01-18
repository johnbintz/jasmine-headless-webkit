require 'multi_json'
require 'erb'
require 'tempfile'
require 'forwardable'

module Jasmine::Headless
  class TemplateWriter
    attr_reader :runner

    extend Forwardable

    def_delegators :runner, :files_list, :options
    def_delegators :options, :reporters

    def initialize(runner)
      @runner = runner
    end

    def write
      output = [
        [ all_tests_filename, files_list.files_to_html ]
      ]

      output.unshift([filtered_tests_filename, files_list.filtered_files_to_html ]) if files_list.filtered?

      output.each do |name, files|
        template = template_for(files)

        File.open(name, 'wb') { |fh| fh.print template }
      end

      output.collect(&:first)
    end

    def all_tests_filename
      runner.runner_filename || "jhw.#{$$}.html"
    end

    def filtered_tests_filename
      all_tests_filename.gsub(%r{\.html$}, '.filter.html')
    end

    def render
      template_for(all_files)
    end

    def all_files
      files_list.files_to_html
    end

    def jhw_reporters
      reporters.collect do |reporter, output|
        %{jasmine.getEnv().addReporter(new jasmine.HeadlessReporter.#{reporter}("#{output}"));}
      end.join("\n")
    end

    private
    def template_for(files)
      spec_lines = files_list.spec_file_line_numbers

      ERB.new(Jasmine::Headless.root.join('skel/template.html.erb').read).result(binding)
    end
  end
end

