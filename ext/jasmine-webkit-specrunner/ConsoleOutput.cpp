#include "ConsoleOutput.h"

ConsoleOutput::ConsoleOutput() : QObject(),
  showColors(false),
  consoleLogUsed(false) {
    outputIO = &std::cout;
  }

void ConsoleOutput::passed(const QString &specDetail) {
  green();
  *outputIO << '.';
  clear();
  outputIO->flush();

  consoleLogUsed = false;
  successes.push(specDetail);
}

void ConsoleOutput::failed(const QString &specDetail) {
  red();
  *outputIO << 'F';
  clear();
  outputIO->flush();

  consoleLogUsed = false;
  failures.push(specDetail);
}

void ConsoleOutput::green() {
  if (showColors) std::cout << "\033[0;32m";
}

void ConsoleOutput::clear() {
  if (showColors) std::cout << "\033[m";
}

void ConsoleOutput::red() {
  if (showColors) std::cout << "\033[0;31m";
}

void ConsoleOutput::yellow()
{
  if (showColors) std::cout << "\033[0;33m";
}

void ConsoleOutput::errorLog(const QString &msg, int lineNumber, const QString &sourceID) {
  red();
  *outputIO << "[error] ";
  clear();
  *outputIO << qPrintable(sourceID) << ":" << lineNumber << " : " << qPrintable(msg);
  *outputIO << std::endl;
}

void ConsoleOutput::internalLog(const QString &note, const QString &msg) {
  red();
  *outputIO << "[" << qPrintable(note) << "] ";
  clear();
  *outputIO << qPrintable(msg);
  *outputIO << std::endl;
}

void ConsoleOutput::consoleLog(const QString &msg) {
  if (!consoleLogUsed) {
    *outputIO << std::endl;
    consoleLogUsed = true;
  }

  green();
  *outputIO << "[console] ";
  if (msg.contains("\n"))
    *outputIO << std::endl;
  clear();
  *outputIO << qPrintable(msg);
  *outputIO << std::endl;
}

void ConsoleOutput::logSpecFilename(const QString &name) {
  *outputIO << std::endl << std::endl;
  red();
  *outputIO << qPrintable(name) << std::endl;
  clear();
}

void ConsoleOutput::logSpecResult(const QString &result) {
  red();
  *outputIO << "  " << qPrintable(result) << std::endl;
  clear();
}

void ConsoleOutput::reportFailure(const QString &totalTests, const QString &failedTests, const QString &duration) {
  red();
  *outputIO << std::endl << "FAIL: ";
  formatTestResults(totalTests, failedTests, duration);
  *outputIO << std::endl;
  clear();
}

void ConsoleOutput::reportSuccess(const QString &totalTests, const QString &failedTests, const QString &duration) {
  green();
  *outputIO << std::endl << "PASS: ";
  formatTestResults(totalTests, failedTests, duration);
  *outputIO << std::endl;
  clear();
}

void ConsoleOutput::reportSuccessWithJSErrors(const QString &totalTests, const QString &failedTests, const QString &duration) {
  yellow();
  *outputIO << std::endl << "PASS with JS errors: ";
  formatTestResults(totalTests, failedTests, duration);
  *outputIO << std::endl;
  clear();
}

void ConsoleOutput::formatTestResults(const QString &totalTests, const QString &failedTests, const QString &duration) {
  *outputIO << qPrintable(totalTests) << " ";
  if (totalTests == "1") {
    *outputIO << "test";
  } else {
    *outputIO << "tests";
  }

  *outputIO << ", ";

  *outputIO << qPrintable(failedTests) << " ";
  if (failedTests == "1") {
    *outputIO << "failure";
  } else {
    *outputIO << "failures";
  }

  *outputIO << ", ";

  *outputIO << qPrintable(duration) << " ";
  if (duration == "1") {
    *outputIO << "sec.";
  } else {
    *outputIO << "secs.";
  }
}

