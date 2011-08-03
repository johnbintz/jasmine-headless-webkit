#include <QtGui>
#include <QtWebKit>

#include "Page.h"

namespace HeadlessSpecRunner {
  Page::Page() : QWebPage(), confirmResult(true) {}

  void Page::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID) {
    emit consoleLog(message, lineNumber, sourceID);
  }

  bool Page::javaScriptConfirm(QWebFrame *frame, const QString &msg) {
    if (confirmResult) {
      emit internalLog("TODO", "jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm for now. Returning true.");
      return true;
    } else {
      confirmResult = true;
      return false;
    }
  }

  void Page::javaScriptAlert(QWebFrame *frame, const QString &msg) {
    emit internalLog("alert", msg);
  }

  void Page::oneFalseConfirm() {
    confirmResult = false;
  }
}
