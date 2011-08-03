#!/usr/bin/env ruby

Dir['*_test.pro'].each do |test|
  system %{make clean && qmake #{test} && make && ./jhw-test}
  if $?.exitstatus != 0
    exit 1
  end
end

