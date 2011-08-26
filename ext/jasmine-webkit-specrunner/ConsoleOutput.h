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
      std::ostream *outputIO;
      QStack<QString> successes;
      QStack<QString> failures;
      bool showColors;
    private:
      void green();
      void clear();
      void red();
  };
}

#endif
