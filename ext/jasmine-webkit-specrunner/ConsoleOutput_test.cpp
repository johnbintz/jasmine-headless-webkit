#include <QtTest/QtTest>

#include "ConsoleOutput.h"
#include "ConsoleOutput_test.h"

using namespace std;

  ConsoleOutputTest::ConsoleOutputTest() : QObject() {}

  void ConsoleOutputTest::testPassed() {
    stringstream buffer;
    ConsoleOutput output;

    output.consoleLogUsed = true;
    output.outputIO = &buffer;
    output.passed("test");
    QVERIFY(buffer.str() == ".");
    QVERIFY(output.successes.size() == 1);
    QVERIFY(output.failures.size() == 0);
    QVERIFY(output.consoleLogUsed == false);
  }

  void ConsoleOutputTest::testFailed() {
    stringstream buffer;
    ConsoleOutput output;

    output.consoleLogUsed = true;
    output.outputIO = &buffer;
    output.failed("test");
    QVERIFY(buffer.str() == "F");
    QVERIFY(output.successes.size() == 0);
    QVERIFY(output.failures.size() == 1);
    QVERIFY(output.consoleLogUsed == false);
  }

  void ConsoleOutputTest::testErrorLog() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.errorLog("message", 1, "source");
    QVERIFY(buffer.str() == "[error] source:1 : message\n");
  }

  void ConsoleOutputTest::testInternalLog() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.internalLog("note", "message");
    QVERIFY(buffer.str() == "[note] message\n");
  }

  void ConsoleOutputTest::testConsoleLog() {
    stringstream buffer;
    ConsoleOutput output;

    output.consoleLogUsed = false;
    output.outputIO = &buffer;
    output.consoleLog("log");
    QVERIFY(buffer.str() == "\n[console] log\n");
  }

  void ConsoleOutputTest::testConsoleLogUsed() {
    stringstream buffer;
    ConsoleOutput output;

    output.consoleLogUsed = true;
    output.outputIO = &buffer;
    output.consoleLog("log");
    QVERIFY(buffer.str() == "[console] log\n");
  }

  void ConsoleOutputTest::testLogSpecFilename() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.logSpecFilename("whatever");
    QVERIFY(buffer.str() == "\n\nwhatever\n");
  }

  void ConsoleOutputTest::testLogSpecResult() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.logSpecResult("whatever");
    QVERIFY(buffer.str() == "  whatever\n");
  }

  void ConsoleOutputTest::testReportResultsFailedSingular() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.reportFailure("1", "1", "1");
    QVERIFY(buffer.str() == "\nFAIL: 1 test, 1 failure, 1 sec.\n");
  }

  void ConsoleOutputTest::testReportResultsFailedPlural() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.reportFailure("2", "2", "2");
    QVERIFY(buffer.str() == "\nFAIL: 2 tests, 2 failures, 2 secs.\n");
  }

  void ConsoleOutputTest::testReportResultsSucceeded() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.reportSuccess("2", "2", "2");
    QVERIFY(buffer.str() == "\nPASS: 2 tests, 2 failures, 2 secs.\n");
  }

  void ConsoleOutputTest::testReportResultsSucceededWithJSErrors() {
    stringstream buffer;
    ConsoleOutput output;

    output.outputIO = &buffer;
    output.reportSuccessWithJSErrors("2", "2", "2");
    QVERIFY(buffer.str() == "\nPASS with JS errors: 2 tests, 2 failures, 2 secs.\n");
  }

QTEST_MAIN(ConsoleOutputTest);

