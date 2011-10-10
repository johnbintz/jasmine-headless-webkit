require 'multi_json'
require 'erb'
require 'tempfile'

module Jasmine::Headless
  class TemplateWriter
    attr_reader :runner

    def initialize(runner)
      @runner = runner
    end

    def write!(files_list)
      output = [
        [ all_tests_filename, files_list.files_to_html ]
      ]

      output.unshift([filtered_tests_filename , files_list.filtered_files_to_html ]) if files_list.filtered?

      output.each do |name, files|
        File.open(name, 'w') { |fh| fh.print template_for(files, files_list.spec_file_line_numbers) }
      end

      output.collect(&:first)
    end

    def all_tests_filename
      runner.runner_filename || "jhw.#{$$}.html"
    end

    def filtered_tests_filename
      all_tests_filename.gsub(%r{\.html$}, '.filter.html')
    end

    private
    def template_for(files, spec_lines)
      ERB.new(Jasmine::Headless.root.join('skel/template.html.erb').read).result(binding)
    end
  end
end

