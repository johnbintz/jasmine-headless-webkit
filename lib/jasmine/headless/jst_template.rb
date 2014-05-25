require 'sprockets/jst_processor'

module Jasmine::Headless
  class JSTTemplate < Sprockets::JstProcessor
    include Jasmine::Headless::FileChecker

    self.default_mime_type = 'application/javascript'

    def evaluate(*args)
      if bad_format?(file)
        alert_bad_format(file)
        return ''
      end
      %{<script type="text/javascript">#{super}</script>}
    end
  end
end

