TEMPLATE = app
CONFIG -= app_bundle
QMAKE_INFO_PLIST = Info.plist
QMAKESPEC = macx-g++
QT += network webkit

SOURCES = Page.cpp Runner.cpp ConsoleOutput.cpp
HEADERS = Page.h Runner.h ConsoleOutput.h

