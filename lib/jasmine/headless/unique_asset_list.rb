module Jasmine::Headless
  class UniqueAssetList < ::Array
    def <<(asset)
      raise StandardError.new("Not an asset") if !asset.respond_to?(:logical_path)

      super if !self.any? { |other| asset.logical_path == other.logical_path }
    end

    def flatten
      self.collect(&:to_a).flatten
    end
  end
end

