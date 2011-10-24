#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <QQueue>

#include "Runner.h"

using namespace std;

Runner::Runner() : QObject()
  , m_runs(0)
  , hasErrors(false)
  , usedConsole(false)
  , isFinished(false)
  , didFail(false)
  {
  m_page.settings()->enablePersistentStorage();
  m_ticker.setInterval(TIMER_TICK);

  connect(&m_ticker, SIGNAL(timeout()), this, SLOT(timerEvent()));
  connect(&m_page, SIGNAL(loadFinished(bool)), this, SLOT(watch(bool)));
  connect(&m_page, SIGNAL(consoleLog(QString, int, QString)), this, SLOT(errorLog(QString, int, QString)));
  connect(&m_page, SIGNAL(internalLog(QString, QString)), this, SLOT(internalLog(QString, QString)));
  connect(m_page.mainFrame(), SIGNAL(javaScriptWindowObjectCleared()), this, SLOT(addJHW()));
}

void Runner::addFile(const QString &spec) {
  runnerFiles.enqueue(spec);
}

void Runner::go()
{
  m_ticker.stop();
  m_page.setPreferredContentsSize(QSize(1024, 600));
  addJHW();

  loadSpec();

  m_ticker.start();
}
void Runner::addJHW()
{
  m_page.mainFrame()->addToJavaScriptWindowObject("JHW", this);
}

void Runner::loadSpec()
{
  if (!reportFileName.isEmpty()) {
    outputFile = new QFile(reportFileName);
    outputFile->open(QIODevice::WriteOnly);

    ts = new QTextStream(outputFile);
  }

  m_page.mainFrame()->load(runnerFiles.dequeue());
  m_ticker.start();
}

void Runner::watch(bool ok)
{
  if (!ok) {
    std::cerr << "Can't load " << qPrintable(m_page.mainFrame()->url().toString()) << ", the file may be broken." << std::endl;
    std::cerr << "Out of curiosity, did your tests try to submit a form and you haven't prevented that?" << std::endl;
    std::cerr << "Try running your tests in your browser with the Jasmine server and see what happens." << std::endl;
    QApplication::instance()->exit(1);
    return;
  }
}

bool Runner::hasElement(const char *select) {
  return !m_page.mainFrame()->findFirstElement(select).isNull();
}

void Runner::setColors(bool colors) {
  consoleOutput.showColors = colors;
}

void Runner::reportFile(const QString &file) {
  reportFileName = file;
}

void Runner::timerPause() {
  m_ticker.stop();
}

void Runner::timerDone() {
  m_ticker.start();
}

void Runner::print(const QString &fh, const QString &content) {
  if (fh == "stdout") {
    std::cout << qPrintable(content);
    std::cout.flush();
  }

  if (fh == "stderr") {
    std::cerr << qPrintable(content);
    std::cerr.flush();
  }

  if (fh == "report") {
    *ts << qPrintable(content);
    ts->flush();
  }
}

void Runner::errorLog(const QString &msg, int lineNumber, const QString &sourceID)
{
  consoleOutput.errorLog(msg, lineNumber, sourceID);
  reportFileOutput.errorLog(msg, lineNumber, sourceID);

  hasErrors = true;
  m_runs = 0;
  m_ticker.start();
}

void Runner::internalLog(const QString &note, const QString &msg) {
  consoleOutput.internalLog(note, msg);
  reportFileOutput.internalLog(note, msg);
}

void Runner::usedConsole()
{
  usedConsole = true;
}

void Runner::leavePageAttempt(const QString &msg)
{
  consoleOutput.internalLog("error", msg);
  m_page.oneFalseConfirm();
  hasErrors = true;
}

void Runner::finishSuite() {
  isFinished = true;
}

void Runner::timerEvent() {
  ++m_runs;

  if (hasErrors && m_runs > 2)
    QApplication::instance()->exit(1);

  if (isFinished) {
    outputFile->close();

    int exitCode = 0;
    if (didFail || hasErrors) {
      exitCode = 1;
    } else {
      if (usedConsole) {
        exitCode = 2;
      }
    }

    bool runAgain = true;

    if (runnerFiles.count() == 0) {
      runAgain = false;
    } else {
      if (exitCode == 1) {
        runAgain = false;
      }
    }

    if (runAgain) {
      isFinished = false;
      loadSpec();
    } else {
      QApplication::instance()->exit(exitCode);
    }
  }

  if (m_runs > MAX_LOOPS) {
    std::cout << "WARNING: too many runs and the test is still not finished!" << std::endl;
    QApplication::instance()->exit(1);
  }
}

