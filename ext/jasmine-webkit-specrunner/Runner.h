#ifndef JHW_RUNNER
#define JHW_RUNNER

#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <fstream>
#include <QQueue>

#include "Page.h"
#include "ConsoleOutput.h"
#include "ReportFileOutput.h"

using namespace std;

class Runner: public QObject {
  Q_OBJECT
  public:
    enum { TIMER_TICK = 200, MAX_LOOPS = 25 };

    Runner();
    void setColors(bool colors);
    void reportFile(const QString &file);
    void addFile(const QString &spec);
    void go();
    public slots:
      void log(const QString &msg);
    bool hasError();
    void leavePageAttempt(const QString &msg);
    void timerPause();
    void timerDone();
    void specPassed(const QString &specDetail);
    void specFailed(const QString &specDetail);
    void printName(const QString &name);
    void printResult(const QString &result);
    void finishSuite(const QString &duration, const QString &total, const QString& failed);
    private slots:
      void watch(bool ok);
    void errorLog(const QString &msg, int lineNumber, const QString &sourceID);
    void internalLog(const QString &note, const QString &msg);
    void addJHW();
    void timerEvent();
  protected:
    bool hasElement(const char *select);
  private:
    Page m_page;
    QTimer m_ticker;
    int m_runs;
    bool hasErrors;
    bool usedConsole;
    bool isFinished;
    bool didFail;
    QQueue<QString> runnerFiles;
    QStack<QString> failedSpecs;

    ConsoleOutput consoleOutput;
    ReportFileOutput reportFileOutput;

    QString reportFileName;

    void loadSpec();
};

#endif
