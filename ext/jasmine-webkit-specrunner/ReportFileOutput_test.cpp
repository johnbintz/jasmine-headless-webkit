#include <QtTest/QtTest>

#include "ReportFileOutput.h"
#include "ReportFileOutput_test.h"

using namespace std;

ReportFileOutputTest::ReportFileOutputTest() : QObject() {}

void ReportFileOutputTest::testPassed() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.passed("test||done||file.js:23");
  QVERIFY(buffer.str() == "PASS||test||done||file.js:23\n");
  QVERIFY(output.successes.size() == 1);
  QVERIFY(output.failures.size() == 0);
}

QTEST_MAIN(ReportFileOutputTest);

