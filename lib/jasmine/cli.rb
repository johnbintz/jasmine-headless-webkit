module Jasmine
  module CLI
    DEFAULTS = {
      'spec_files' => [ '**/*[sS]pec.js' ],
      'helpers' => [ 'helpers/**/*.js' ],
      'spec_dir' => 'spec/javascripts',
      'src_dir' => nil,
      'stylesheets' => [],
      'src_files' => []
    }

    DEFAULTS_FILE = '.jasmine-headless-webkit'

    def process_jasmine_config(overrides = {})
      DEFAULTS.merge(overrides)
    end

    def read_defaults_file
      File.readlines(DEFAULTS_FILE).collect { |line| line.strip.split(' ', 2) }.each(&@process_options)
    end

    def defaults_file?
      File.file?(DEFAULTS_FILE)
    end
  end
end

