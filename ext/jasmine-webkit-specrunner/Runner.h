#ifndef JHW_RUNNER
#define JHW_RUNNER

#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <QQueue>

#include "Page.h"
#include "ConsoleOutput.h"

namespace HeadlessSpecRunner {
  class Runner: public QObject {
    Q_OBJECT
    public:
      Runner();
      void setColors(bool colors);
      void reportFile(const QString &file);
      void addFile(const QString &spec);
      void go();
    public slots:
      void log(const QString &msg);
      bool hasError();
      void leavePageAttempt(const QString &msg);
      void specPassed();
      void specFailed(const QString &specDetail);
      void printName(const QString &name);
      void printResult(const QString &result);
      void finishSuite(const QString &duration, const QString &total, const QString& failed);
    private slots:
      void watch(bool ok);
      void errorLog(const QString &msg, int lineNumber, const QString &sourceID);
      void internalLog(const QString &note, const QString &msg);
      void addJHW();
    protected:
      bool hasElement(const char *select);
      void timerEvent(QTimerEvent *event);
    private:
      HeadlessSpecRunner::Page m_page;
      QBasicTimer m_ticker;
      int m_runs;
      bool hasErrors;
      bool usedConsole;
      bool showColors;
      bool isFinished;
      bool didFail;
      QQueue<QString> runnerFiles;
      QString reportFilename;
      QStack<QString> failedSpecs;

      HeadlessSpecRunner::ConsoleOutput consoleOutput;

      void red();
      void green();
      void yellow();
      void clear();
      void loadSpec();
  };
}

#endif
