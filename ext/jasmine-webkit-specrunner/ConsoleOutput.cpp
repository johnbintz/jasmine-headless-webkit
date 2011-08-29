#include "ConsoleOutput.h"

namespace HeadlessSpecRunner {
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

  void ConsoleOutput::failed(const QString &specDetail)
  {
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
}

