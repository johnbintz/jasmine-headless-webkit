module Digest
  class JasmineTest
    def self.file(file)
      new
    end

    def file(file)
      self
    end

    def hexdigest
      'test'
    end

    def update(prefix)
      self
    end
  end
end

