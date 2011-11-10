TEMPLATE = app
CONFIG -= app_bundle
QMAKE_INFO_PLIST = Info.plist
QMAKESPEC = macx-g++
QT += network webkit

SOURCES = Page.cpp Runner.cpp
HEADERS = Page.h Runner.h

