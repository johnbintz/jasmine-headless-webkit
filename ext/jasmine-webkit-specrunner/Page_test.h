#ifndef JHW_TEST_PAGE
#define JHW_TEST_PAGE

#include <QtTest/QtTest>

#include "Page.h"

namespace HeadlessSpecRunner {
  class PageTest : public QObject {
    Q_OBJECT
    public:
      PageTest();

    private:
      bool internalLogCalled;
      bool consoleLogCalled;
      HeadlessSpecRunner::Page page;

    private slots:
      void internalLog(const QString &note, const QString &msg);
      void consoleLog(const QString &message, int lineNumber, const QString &source);
      void testJavaScriptConfirmWithLog();
      void testJavaScriptConfirmWithoutLog();
      void testJavaScriptConsoleMessage();
  };
}

#endif

