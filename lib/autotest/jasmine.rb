require 'autotest'
require 'autotest/jasmine_mixin'

class Autotest::Jasmine < Autotest
  include JasmineMixin
end

