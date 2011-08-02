require 'fileutils'

$: << File.expand_path("../../../lib", __FILE__)

require 'qt/qmake'

Qt::Qmake.make!('jasmine-headless-webkit tests', 'specrunner_test.pro')
system %{jasmine-webkit-specrunner-test}
Qt::Qmake.make!('jasmine-headless-webkit', 'specrunner.pro')

