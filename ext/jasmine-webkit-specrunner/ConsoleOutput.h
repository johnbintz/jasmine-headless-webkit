#ifndef JHW_CONSOLE_OUTPUT
#define JHW_CONSOLE_OUTPUT

#include <QObject>
#include <iostream>
#include <QStack>

namespace HeadlessSpecRunner {
  class ConsoleOutput : public QObject {
    Q_OBJECT
    public:
      ConsoleOutput();
      void passed(const QString &specDetail);
      void failed(const QString &specDetail);
      void errorLog(const QString &msg, int lineNumber, const QString &sourceID);
      void internalLog(const QString &note, const QString &msg);
      void consoleLog(const QString &msg);
      void logSpecFilename(const QString &name);
      void logSpecResult(const QString &result);

      void reportFailure(const QString &totalTests, const QString &failedTests, const QString &duration);
      void reportSuccess(const QString &totalTests, const QString &failedTests, const QString &duration);
      void reportSuccessWithJSErrors(const QString &totalTests, const QString &failedTests, const QString &duration);

      std::ostream *outputIO;
      QStack<QString> successes;
      QStack<QString> failures;
      bool showColors;
      bool consoleLogUsed;
    private:
      void green();
      void clear();
      void red();
      void yellow();
      void formatTestResults(const QString &totalTests, const QString &failedTests, const QString &duration);
  };
}

#endif
