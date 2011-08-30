#ifndef JHW_TEST_PAGE
#define JHW_TEST_PAGE

#include <QtTest/QtTest>
#include <iostream>
#include <sstream>
#include <string>

#include "ConsoleOutput.h"

namespace HeadlessSpecRunner {
  class ConsoleOutputTest : public QObject {
    Q_OBJECT
    public:
      ConsoleOutputTest();

    private slots:
      void testPassed();
      void testFailed();
      void testErrorLog();
      void testInternalLog();
      void testConsoleLog();
      void testConsoleLogUsed();
      void testLogSpecFilename();
      void testLogSpecResult();

      void testReportResultsFailedSingular();
      void testReportResultsFailedPlural();
      void testReportResultsSucceeded();
      void testReportResultsSucceededWithJSErrors();
  };
}

#endif

