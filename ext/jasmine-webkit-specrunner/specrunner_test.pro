TEMPLATE = app
CONFIG -= app_bundle
TARGET = jasmine-webkit-specrunner-test
SOURCES = HeadlessSpecRunner/Page.cpp \
          HeadlessSpecRunner/Runner.cpp \
          Test/Page_test.cpp \
          specrunner_test.cpp

HEADERS = HeadlessSpecRunner/Page.h \
          HeadlessSpecRunner/Runner.h \
          Test/Page_test.h

QT += network webkit testlib
QMAKE_INFO_PLIST = Info.plist
QMAKESPEC = macx-gcc

