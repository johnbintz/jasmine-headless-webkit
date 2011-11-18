require 'multi_json'

module Jasmine::Headless
  class SpecFileAnalyzer < CacheableAction
    class << self
      def cache_type
        "spec_file_analysis"
      end
    end

    def action
      line_numbers = {}

      data = File.read(file)

      if data.respond_to?(:encode)
        data.encode!('US-ASCII', 'UTF-8', :invalid => :replace, :undef => :replace)
      else
        require 'iconv'
        ic = Iconv.new('UTF-8//IGNORE', 'US-ASCII')
        data = ic.iconv(File.read(file) + ' ')[0..-2]
      end

      data.force_encoding('US-ASCII') if data.respond_to?(:force_encoding)

      data.lines.each_with_index.each { |line, index|
        if description = line[%r{(describe|context|it)[( ]*(["'])(.*)\2}, 3]
          (line_numbers[description] ||= []) << (index + 1)
        end
      }

      line_numbers
    end

    def serialize(data)
      MultiJson.encode(data)
    end

    def unserialize(data)
      MultiJson.decode(data)
    end
  end
end

