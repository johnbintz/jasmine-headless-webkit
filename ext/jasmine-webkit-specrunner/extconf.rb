require 'fileutils'

$: << File.expand_path("../../../lib", __FILE__)

require 'qt/qmake'

Qt::Qmake.make!('jasmine-headless-webkit')

