TEMPLATE = app
CONFIG -= app_bundle
TARGET = jasmine-webkit-specrunner
SOURCES = HeadlessSpecRunner/Page.cpp HeadlessSpecRunner/Runner.cpp specrunner.cpp
HEADERS = HeadlessSpecRunner/Page.h HeadlessSpecRunner/Runner.h
QT += network webkit
QMAKE_INFO_PLIST = Info.plist
QMAKESPEC = macx-gcc
