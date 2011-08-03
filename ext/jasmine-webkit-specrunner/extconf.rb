require 'fileutils'

$: << File.expand_path("../../../lib", __FILE__)

require 'qt/qmake'

system %{make clean}
Qt::Qmake.make!('jasmine-headless-webkit', 'specrunner.pro')

