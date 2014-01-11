require 'fileutils'

$: << File.expand_path("../../../lib", __FILE__)

require 'qt/qmake'

system %{make clean}
Qt::Qmake.make!('jasmine-headless-webkit', 'specrunner.pro')

# The build above can fail silently. So we check for the existence of the binary.
raise "\n***********************\nGem jasmine-headless-webkit-firstbanco failed to build. Have you got qtmake installed? On linux you need: sudo apt-get install libqtwebkit-dev qt4-dev-tools" unless File.exist?(File.expand_path('../jasmine-webkit-specrunner', __FILE__))

FileUtils.cp File.expand_path('../Makefile.dummy', __FILE__), File.expand_path('../Makefile', __FILE__)
