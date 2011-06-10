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

    RUNNER = 'ext/jasmine-webkit-specrunner/jasmine-webkit-specrunner'
    DEFAULTS_FILE = '.jasmine-headless-webkit'
    GLOBAL_DEFAULTS_FILE = File.expand_path("~/#{DEFAULTS_FILE}")

    def load_config(file)
      process_jasmine_config(YAML.load_file(file))
    end

    def process_jasmine_config(overrides = {})
      DEFAULTS.merge(overrides)
    end

    def read_defaults_files!
      [ GLOBAL_DEFAULTS_FILE, DEFAULTS_FILE ].each do |file|
        if File.file?(file)
          File.readlines(file).collect { |line| line.strip.split(' ', 2) }.each(&@process_options)
        end
      end
    end

    def jasmine_html_template(files)
      <<-HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
  <title>Jasmine Test Runner</title>
  <script type="text/javascript">
    window.console = { log: function(data) { 
      JHW.log(JSON.stringify(data));
    }, pp: function(data) {
      JHW.log(jasmine ? jasmine.pp(data) : JSON.stringify(data));
    } };
  </script>
  #{files.join("\n")}
</head>
<body>

<script type="text/javascript">
  jasmine.getEnv().addReporter(new jasmine.HeadlessReporter());
  jasmine.getEnv().execute();
</script>

</body>
</html>
      HTML
    end

    def runner_path
      @runner_path ||= File.join(gem_dir, RUNNER)
    end

    def jasmine_command(options, target)
      [
        runner_path,
        options[:colors] ? '-c' : nil,
        options[:report] ? "-r #{options[:report]}" : nil,
        target
      ].join(" ")
    end

    private
    def read_config_file(file)

    end
  end
end

