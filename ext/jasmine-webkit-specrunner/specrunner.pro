TEMPLATE = app
CONFIG -= app_bundle
TARGET = jasmine-webkit-specrunner
SOURCES = specrunner.cpp
QT += network webkit
QMAKE_INFO_PLIST = Info.plist
QMAKESPEC = macx-gcc
