#include "ConsoleOutput.h"

namespace HeadlessSpecRunner {
  ConsoleOutput::ConsoleOutput() : QObject(),
  showColors(false) {
    outputIO = &std::cout;
  }

  void ConsoleOutput::passed(const QString &specDetail) {
    green();
    *outputIO << '.';
    clear();
    outputIO->flush();

    successes.push(specDetail);
  }

  void ConsoleOutput::failed(const QString &specDetail)
  {
    red();
    *outputIO << 'F';
    clear();
    outputIO->flush();

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
}
