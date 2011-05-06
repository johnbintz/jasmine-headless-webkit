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

    def process_jasmine_config(overrides = {})
      DEFAULTS.merge(overrides)
    end
  end
end

