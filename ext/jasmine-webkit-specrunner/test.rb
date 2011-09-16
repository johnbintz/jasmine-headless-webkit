#!/usr/bin/env ruby

require 'fileutils'

system %{make clean}

$: << File.expand_path("../../../lib", __FILE__)
require 'qt/qmake'

result = 0

Dir['*_test.pro'].each do |test|
  FileUtils.rm_f('jhw-test')

  Qt::Qmake.make!('jasmine-headless-webkit', test)

  if File.file?('jhw-test')
    system %{./jhw-test}
    if $?.exitstatus != 0
      result = 1
      break
    end
  else
    result = 1
    break
  end
end

Qt::Qmake.make!('jasmine-headless-webkit', 'specrunner.pro')

exit result
