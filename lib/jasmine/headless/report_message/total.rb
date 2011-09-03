module Jasmine::Headless::ReportMessage
  class Total
    class << self
      def new_from_parts(parts)
        new(*parts)
      end
    end

    attr_reader :total, :failed, :time, :has_js_error

    def initialize(total, failed, time, has_js_error)
      @total, @failed, @time = total.to_i, failed.to_i, time.to_f

      @has_js_error = case has_js_error
      when String
        has_js_error == "T"
      else
        has_js_error
      end
    end

    def ==(other)
      other &&
      self.total == other.total &&
      self.failed == other.failed &&
      self.time == other.time &&
      self.has_js_error == other.has_js_error
    end
  end
end

