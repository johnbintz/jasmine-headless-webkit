module Jasmine::Headless::ReportMessage
  class Seed
    def self.new_from_parts(parts)
      new(parts.first)
    end

    attr_reader :seed

    def initialize(seed)
      @seed = seed.to_i
    end
  end
end

