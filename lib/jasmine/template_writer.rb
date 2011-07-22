require 'jasmine/files_list'
require 'multi_json'

module Jasmine
  class TemplateWriter
    class << self
      def write!(files_list)
        output = [
          [ "specrunner.#{$$}.html", files_list.files_to_html ]
        ]

        output.unshift([ "specrunner.#{$$}.filter.html", files_list.filtered_files_to_html ]) if files_list.filtered?

        output.each do |name, files|
          File.open(name, 'w') { |fh| fh.print template_for(files, files_list.spec_file_line_numbers) }
        end

        output.collect(&:first)
      end

      private
      def template_for(files, spec_lines)
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

    window.onbeforeunload = function(e) {
      JHW.leavePageAttempt('The code tried to leave the test page. Check for unhandled form submits and link clicks.');

      if (e = e || window.event) {
        e.returnValue = "leaving";
      }

      return "leaving";
    };
  </script>
  #{files.join("\n")}
  <script type="text/javascript">
HeadlessReporterResult.specLineNumbers = #{MultiJson.encode(spec_lines)};
  </script>
</head>
<body>

<script type="text/javascript">
  jasmine.getEnv().addReporter(new jasmine.HeadlessReporter(function() {
    window.onbeforeunload = null;
  }));
  jasmine.getEnv().execute();
</script>

</body>
</html>
HTML
      end
    end
  end
end

