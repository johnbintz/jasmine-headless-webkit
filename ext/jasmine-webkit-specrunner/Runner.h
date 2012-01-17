#ifndef JHW_RUNNER
#define JHW_RUNNER

#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <fstream>
#include <sstream>
#include <QQueue>
#include <QApplication>

#include "Page.h"

using namespace std;

class Runner: public QObject {
  Q_OBJECT
  public:
    enum { TIMER_TICK = 200, MAX_LOOPS = 50 };

    Runner();
    void setColors(bool colors);
    void setReportFiles(QStack<QString> &files);
    void setSeed(QString s);
    void setQuiet(bool q);

    void addFile(const QString &spec);
    void go();

  public slots:
    void timerPause();
    void timerDone();
    void hasUsedConsole();
    void hasError();
    void hasSpecFailure();

    bool isQuiet();
    QString getSeed();

    void print(const QString &fh, const QString &content);
    void finishSuite();
    void ping();

  private slots:
    void watch(bool ok);
    void addJHW();
    void timerEvent();
    void handleError(const QString & message, int lineNumber, const QString & sourceID);

  private:
    Page page;
    QTimer ticker;
    int runs;
    bool hasErrors;
    bool _hasSpecFailure;
    bool usedConsole;
    bool isFinished;
    bool useColors;
    bool quiet;

    QString seed;

    QQueue<QString> runnerFiles;
    QStack<QString> reportFiles;

    void loadSpec();

    QQueue<QFile *> outputFiles;
};

#endif
