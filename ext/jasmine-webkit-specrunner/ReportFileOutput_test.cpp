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

void ReportFileOutputTest::testFailed() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.failed("test||done||file.js:23");
  QVERIFY(buffer.str() == "FAIL||test||done||file.js:23\n");
  QVERIFY(output.successes.size() == 0);
  QVERIFY(output.failures.size() == 1);
}

void ReportFileOutputTest::testErrorLog() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.errorLog("JS Error", 23, "file.js");
  QVERIFY(buffer.str() == "ERROR||JS Error||file.js:23\n");
}

void ReportFileOutputTest::testConsoleLog() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.consoleLog("Console");
  QVERIFY(buffer.str() == "CONSOLE||Console\n");
}

void ReportFileOutputTest::testStubMethods() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.internalLog("Internal", "Log");
  output.logSpecFilename("Filename");
  output.logSpecResult("REsult");
}

void ReportFileOutputTest::testReportFailure() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.reportFailure("5", "2", "1.5");
  QVERIFY(buffer.str() == "TOTAL||5||2||1.5||F\n");
}

void ReportFileOutputTest::testReportSuccess() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.reportSuccess("5", "0", "1.5");
  QVERIFY(buffer.str() == "TOTAL||5||0||1.5||F\n");
}

void ReportFileOutputTest::testReportSuccessWithJSErrors() {
  stringstream buffer;
  ReportFileOutput output;

  output.outputIO = &buffer;
  output.reportSuccessWithJSErrors("5", "0", "1.5");
  QVERIFY(buffer.str() == "TOTAL||5||0||1.5||T\n");
}

QTEST_MAIN(ReportFileOutputTest);

