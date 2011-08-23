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

    output.outputIO = &buffer;
    output.passed("test");
    QVERIFY(buffer.str() == ".");
    QVERIFY(output.successes.size() == 1);
    QVERIFY(output.failures.size() == 0);
  }

  void ConsoleOutputTest::testFailed() {
    stringstream buffer;
    HeadlessSpecRunner::ConsoleOutput output;

    output.outputIO = &buffer;
    output.failed("test");
    QVERIFY(buffer.str() == "F");
    QVERIFY(output.successes.size() == 0);
    QVERIFY(output.failures.size() == 1);
  }
}

QTEST_MAIN(HeadlessSpecRunner::ConsoleOutputTest);

