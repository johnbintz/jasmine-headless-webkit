#ifndef JHW_TEST_REPORT_FILE_OUTPUT
#define JHW_TEST_REPORT_FILE_OUTPUT

#include <QtTest/QtTest>
#include <iostream>
#include <sstream>
#include <string>

#include "ReportFileOutput.h"

class ReportFileOutputTest : public QObject {
  Q_OBJECT
  public:
    ReportFileOutputTest();
  private slots:
    void testPassed();
    void testFailed();
};

#endif
