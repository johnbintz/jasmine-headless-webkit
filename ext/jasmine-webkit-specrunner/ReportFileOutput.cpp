#include "ReportFileOutput.h"

using namespace std;

ReportFileOutput::ReportFileOutput() : QObject() {
  reset();
}

void ReportFileOutput::reset() {
  buffer = new stringstream();

  outputIO = buffer;
}

void ReportFileOutput::passed(const QString &specDetail) {
  *outputIO << "PASS||" << qPrintable(specDetail) << std::endl;
  successes.push(specDetail);
}

void ReportFileOutput::failed(const QString &specDetail) {
  *outputIO << "FAIL||" << qPrintable(specDetail) << std::endl;
  failures.push(specDetail);
}

void ReportFileOutput::errorLog(const QString &msg, int lineNumber, const QString &sourceID) {
  *outputIO << "ERROR||" << qPrintable(msg) << "||" << qPrintable(sourceID) << ":" << lineNumber << std::endl;
}

void ReportFileOutput::consoleLog(const QString &msg) {
  *outputIO << "CONSOLE||" << qPrintable(msg) << std::endl;
}

void ReportFileOutput::internalLog(const QString &, const QString &) {}
void ReportFileOutput::logSpecFilename(const QString &) {}
void ReportFileOutput::logSpecResult(const QString &) {}

void ReportFileOutput::reportFailure(const QString &totalTests, const QString &failedTests, const QString &duration) {
  reportTotals(totalTests, failedTests, duration, false);
}

void ReportFileOutput::reportSuccess(const QString &totalTests, const QString &failedTests, const QString &duration) {
  reportTotals(totalTests, failedTests, duration, false);
}

void ReportFileOutput::reportSuccessWithJSErrors(const QString &totalTests, const QString &failedTests, const QString &duration) {
  reportTotals(totalTests, failedTests, duration, true);
}

void ReportFileOutput::reportTotals(const QString &totalTests, const QString &failedTests, const QString &duration, bool hasJavaScriptError) {
  *outputIO << "TOTAL||" << qPrintable(totalTests) << "||" << qPrintable(failedTests) << "||" << qPrintable(duration) << "||";
  *outputIO << (hasJavaScriptError ? "T" : "F");
  *outputIO << std::endl;
}

