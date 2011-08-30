#ifndef JHW_TEST_CONSOLE_OUTPUT
#define JHW_TEST_CONSOLE_OUTPUT

#include <QtTest/QtTest>
#include <iostream>
#include <sstream>
#include <string>

#include "ConsoleOutput.h"

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

#endif
