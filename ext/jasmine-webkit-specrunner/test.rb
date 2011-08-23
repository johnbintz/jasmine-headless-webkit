#!/usr/bin/env ruby

system %{make clean}

Dir['*_test.pro'].each do |test|
  $: << File.expand_path("../../../lib", __FILE__)

  require 'qt/qmake'
  Qt::Qmake.make!('jasmine-headless-webkit', test)

  system %{./jhw-test}
  if $?.exitstatus != 0
    exit 1
  end
end

