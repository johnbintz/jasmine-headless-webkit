TEMPLATE = app
CONFIG -= app_bundle
TARGET = jasmine-webkit-specrunner-test
SOURCES = HeadlessSpecRunner/Page.cpp \
          HeadlessSpecRunner/Runner.cpp \
          Test/Page_test.cpp

HEADERS = HeadlessSpecRunner/Page.h \
          HeadlessSpecRunner/Runner.h \
          Test/Page_test.h

QT += network webkit
QMAKE_INFO_PLIST = Info.plist
QMAKESPEC = macx-gcc

LIBS += -L/Users/john/Projects/unit++/lib -lunit++
INCLUDEPATH += /Users/john/Projects/unit++/include

