require 'sprockets'
require 'forwardable'

module Jasmine::Headless
  class PathSearcher
    extend Forwardable

    def_delegators :source, :search_paths, :extension_filter

    attr_reader :source

    def initialize(source)
      @source = source
    end

    def find(file)
      search_paths.each do |dir|
        Dir[File.join(dir, "#{file}*")].find_all { |path| File.file?(path) }.each do |path|
          root = path.gsub(%r{^#{dir}/}, '')

          ok = (root == file)
          ok ||= File.basename(path.gsub("#{file}.", '')).split('.').all? { |part| ".#{part}"[extension_filter] }

          if ok
            return [ File.expand_path(path), dir ]
          end
        end
      end

      false
    end
  end
end

