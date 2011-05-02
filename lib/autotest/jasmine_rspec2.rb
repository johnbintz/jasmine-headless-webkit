require 'autotest/rspec2'
require 'autotest/jasmine_mixin'

class Autotest::JasmineRspec2 < Autotest::Rspec2
  include JasmineMixin
end

