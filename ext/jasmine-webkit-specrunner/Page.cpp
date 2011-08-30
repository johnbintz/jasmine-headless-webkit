#include <QtGui>
#include <QtWebKit>
#include <iostream>

#include "Page.h"

  Page::Page() : QWebPage(), confirmResult(true) {}

  void Page::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID) {
    emit consoleLog(message, lineNumber, sourceID);
  }

  bool Page::javaScriptConfirm(QWebFrame*, const QString&) {
    if (confirmResult) {
      emit internalLog("TODO", "jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm for now. Returning true.");
      return true;
    } else {
      confirmResult = true;
      return false;
    }
  }

  void Page::javaScriptAlert(QWebFrame*, const QString &msg) {
    emit internalLog("alert", msg);
  }

  void Page::oneFalseConfirm() {
    confirmResult = false;
  }
