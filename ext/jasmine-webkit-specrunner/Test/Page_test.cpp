#include <QtGui>
#include <QtWebKit>
#include <unit++.h>

#include "HeadlessSpecRunner/Page.h"
#include "Test/Page_test.h"

using namespace unitpp;

namespace HeadlessSpecRunner {
  PageTestHelper::PageTestHelper() : QObject(), internalLogCalled(false) {}

  void PageTestHelper::addPage(HeadlessSpecRunner::Page &page) {
    connect(&page, SIGNAL(internalLog(QString, QString)), this, SLOT(internalLog(QString, QString)));
  }

  void PageTestHelper::internalLog(const QString &note, const QString &msg) {
    internalLogCalled = true;
  }

  PageTest::PageTest() : suite("suite") {
    add("test", testcase(this, "test", &HeadlessSpecRunner::PageTest::testJavaScriptConfirmWithLog));
    suite::main().add("test", this);
  }

  void PageTest::testJavaScriptConfirmWithLog() {
    helper.addPage(page);
    helper.internalLogCalled = false;

    page.mainFrame()->setHtml("<script>confirm('test')</script>");
    assert_true("internal log called", helper.internalLogCalled);
  }
}

HeadlessSpecRunner::PageTest *one = new HeadlessSpecRunner::PageTest();

