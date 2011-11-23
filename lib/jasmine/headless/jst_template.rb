require 'sprockets/jst_processor'

module Jasmine::Headless
  class JSTTemplate < Sprockets::JstProcessor
    def evaluate(*args)
      %{<script type="text/javascript">#{super}</script>}
    end
  end
end

