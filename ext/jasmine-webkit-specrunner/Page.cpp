#include <QtGui>
#include <QtWebKit>
#include <iostream>

#include "Page.h"

Page::Page() : QWebPage() {}

void Page::javaScriptConsoleMessage(const QString & message, int lineNumber, const QString & sourceID) {
  emit handleError(message, lineNumber, sourceID);
}

void Page::javaScriptAlert(QWebFrame *, const QString &) {}
bool Page::javaScriptConfirm(QWebFrame *, const QString &) {
  return false;
}
