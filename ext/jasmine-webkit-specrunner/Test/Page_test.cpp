#include <QtTest/QtTest>

#include "HeadlessSpecRunner/Page.h"
#include "Test/Page_test.h"

namespace HeadlessSpecRunner {
  PageTest::PageTest() : QObject(), internalLogCalled(false) {
  }

  void PageTest::internalLog(const QString &note, const QString &msg) {
    internalLogCalled = true;
  }

  void PageTest::consoleLog(const QString &message, int lineNumber, const QString &source) {
    consoleLogCalled = true;
  }

  void PageTest::testJavaScriptConfirmWithLog() {
    connect(&page, SIGNAL(internalLog(QString, QString)), this, SLOT(internalLog(QString, QString)));
    internalLogCalled = false;

    page.mainFrame()->setHtml("<script>confirm('test')</script>");
    QVERIFY(internalLogCalled);
  }

  void PageTest::testJavaScriptConfirmWithoutLog() {
    connect(&page, SIGNAL(internalLog(QString, QString)), this, SLOT(internalLog(QString, QString)));
    internalLogCalled = false;

    page.oneFalseConfirm();
    page.mainFrame()->setHtml("<script>confirm('test')</script>");
    QVERIFY(!internalLogCalled);
  }

  void PageTest::testJavaScriptConsoleMessage() {
    connect(&page, SIGNAL(consoleLog(QString, int, QString)), this, SLOT(consoleLog(QString, int, QString)));
    consoleLogCalled = false;

    page.mainFrame()->setHtml("<script>cats();</script>");
    QVERIFY(consoleLogCalled);
  }
}

