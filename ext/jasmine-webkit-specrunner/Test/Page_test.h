#ifndef JHW_TEST_PAGE
#define JHW_TEST_PAGE

#include <QtGui>
#include <QtWebKit>
#include <unit++.h>

#include "HeadlessSpecRunner/Page.h"

using namespace unitpp;

namespace HeadlessSpecRunner {
  class PageTestHelper : public QObject {
    Q_OBJECT
    public:
      PageTestHelper();
      bool internalLogCalled;
      void addPage(HeadlessSpecRunner::Page &page);

    public slots:
      void internalLog(const QString &note, const QString &msg);
  };

  class PageTest : public suite {
    public:
      PageTest();
      HeadlessSpecRunner::Page page;
      HeadlessSpecRunner::PageTestHelper helper;

      void testJavaScriptConfirmWithLog();
  };
}

#endif
