TEMPLATE = app
CONFIG -= app_bundle
QMAKE_INFO_PLIST = Info.plist
QT += network
greaterThan(QT_MAJOR_VERSION, 4) {
  QT += webkitwidgets
} else {
  QT += webkit
}

SOURCES = Page.cpp Runner.cpp
HEADERS = Page.h Runner.h

