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

using namespace std;

class Runner: public QObject {
  Q_OBJECT
  public:
    enum { TIMER_TICK = 200, MAX_LOOPS = 50 };

    Runner();
    void setColors(bool colors);
    void reportFile(const QString &file);
    void addFile(const QString &spec);
    void go();
  public slots:
    void timerPause();
    void timerDone();

    void print(const QString &fh, const QString &content);

    void finishSuite();
  private slots:
    void watch(bool ok);
    void addJHW();
    void timerEvent();
    void handleError(const QString & message, int lineNumber, const QString & sourceID);
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
    bool useColors;

    QQueue<QString> runnerFiles;
    QStack<QString> failedSpecs;

    QString reportFileName;

    void loadSpec();

    QFile *outputFile;
    QTextStream *ts;
};

#endif
