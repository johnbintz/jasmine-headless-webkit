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

bool Runner::hasElement(const char *select)
{
  return !m_page.mainFrame()->findFirstElement(select).isNull();
}

void Runner::setColors(bool colors) {
  consoleOutput.showColors = colors;
}

void Runner::reportFile(const QString &file) {
  reportFileName = file;
}

bool Runner::hasError() {
  return hasErrors;
}

void Runner::timerPause() {
  m_ticker.stop();
}

void Runner::timerDone() {
  m_ticker.start();
}

void Runner::specPassed(const QString &specDetail) {
  consoleOutput.passed(specDetail);
  reportFileOutput.passed(specDetail);
}

void Runner::specFailed(const QString &specDetail) {
  consoleOutput.failed(specDetail);
  reportFileOutput.failed(specDetail);

  didFail = true;
  failedSpecs.push(specDetail);
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

void Runner::log(const QString &msg)
{
  usedConsole = true;
  consoleOutput.consoleLog(msg);
  reportFileOutput.consoleLog(msg);
}

void Runner::leavePageAttempt(const QString &msg)
{
  consoleOutput.internalLog("error", msg);
  m_page.oneFalseConfirm();
  hasErrors = true;
}

void Runner::printName(const QString &name)
{
  consoleOutput.logSpecFilename(name);
}

void Runner::printResult(const QString &result)
{
  consoleOutput.logSpecResult(result);
}

void Runner::finishSuite(const QString &duration, const QString &total, const QString& failed)
{
  if (didFail) {
    consoleOutput.reportFailure(total, failed, duration);
    reportFileOutput.reportFailure(total, failed, duration);
  } else {
    if (hasErrors) {
      consoleOutput.reportSuccessWithJSErrors(total, failed, duration);
      reportFileOutput.reportSuccessWithJSErrors(total, failed, duration);
    } else {
      consoleOutput.reportSuccess(total, failed, duration);
      reportFileOutput.reportSuccess(total, failed, duration);
    }
  }

  if (!reportFileName.isEmpty()) {
    QFile outputFile(reportFileName);
    outputFile.open(QIODevice::WriteOnly);

    QTextStream ts(&outputFile);

    ts << reportFileOutput.outputIO->str().c_str();

    outputFile.close();
  }

  isFinished = true;
}

void Runner::timerEvent()
{
  ++m_runs;

  if (hasErrors && m_runs > 2)
    QApplication::instance()->exit(1);

  if (isFinished) {
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

