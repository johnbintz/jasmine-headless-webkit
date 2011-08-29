#include <QtTest/QtTest>

#include "ConsoleOutput.h"
#include "ConsoleOutput_test.h"

using namespace std;

namespace HeadlessSpecRunner {
  ConsoleOutputTest::ConsoleOutputTest() : QObject() {
  }

  void ConsoleOutputTest::testPassed() {
    stringstream buffer;
    HeadlessSpecRunner::ConsoleOutput output;

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
    HeadlessSpecRunner::ConsoleOutput output;

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
    HeadlessSpecRunner::ConsoleOutput output;

    output.outputIO = &buffer;
    output.errorLog("message", 1, "source");
    QVERIFY(buffer.str() == "[error] source:1 : message\n");
  }

  void ConsoleOutputTest::testInternalLog() {
    stringstream buffer;
    HeadlessSpecRunner::ConsoleOutput output;

    output.outputIO = &buffer;
    output.internalLog("note", "message");
    QVERIFY(buffer.str() == "[note] message\n");
  }

  void ConsoleOutputTest::testConsoleLog() {
    stringstream buffer;
    HeadlessSpecRunner::ConsoleOutput output;

    output.consoleLogUsed = false;
    output.outputIO = &buffer;
    output.consoleLog("log");
    QVERIFY(buffer.str() == "\n[console] log\n");
  }

  void ConsoleOutputTest::testConsoleLogUsed() {
    stringstream buffer;
    HeadlessSpecRunner::ConsoleOutput output;

    output.consoleLogUsed = true;
    output.outputIO = &buffer;
    output.consoleLog("log");
    QVERIFY(buffer.str() == "[console] log\n");
  }

  void ConsoleOutputTest::testLogSpecFilename() {
    stringstream buffer;
    HeadlessSpecRunner::ConsoleOutput output;

    output.outputIO = &buffer;
    output.logSpecFilename("whatever");
    QVERIFY(buffer.str() == "\n\nwhatever\n");
  }
}

QTEST_MAIN(HeadlessSpecRunner::ConsoleOutputTest);

