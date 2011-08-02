#ifndef JHW_CONSOLE_REPORTER
#define JHW_CONSOLE_REPORTER

namespace HeadlessSpecRunner {
  class ConsoleReporter : public QObject {
    Q_OBJECT
    public:
      ConsoleReporter();
      void passed(const QString &specDetail);
      void failed(const QString &specDetail);
  }
}

#endif
