#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <QQueue>

#include "Runner.h"

namespace HeadlessSpecRunner {
  Runner::Runner() : QObject()
    , m_runs(0)
    , hasErrors(false)
    , usedConsole(false)
    , showColors(false)
    , isFinished(false)
    , didFail(false)
    , consoleNotUsedThisRun(false) {
    m_page.settings()->enablePersistentStorage();
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
  }
  void Runner::addJHW()
  {
    m_page.mainFrame()->addToJavaScriptWindowObject("JHW", this);
  }

  void Runner::loadSpec()
  {
    m_page.mainFrame()->load(runnerFiles.dequeue());
    m_ticker.start(200, this);
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

    m_ticker.start(200, this);
  }

  bool Runner::hasElement(const char *select)
  {
    return !m_page.mainFrame()->findFirstElement(select).isNull();
  }

  void Runner::setColors(bool colors)
  {
    showColors = colors;
  }

  void Runner::reportFile(const QString &file)
  {
    reportFilename = file;
  }

  void Runner::red()
  {
    if (showColors) std::cout << "\033[0;31m";
  }

  void Runner::green()
  {
    if (showColors) std::cout << "\033[0;32m";
  }

  void Runner::yellow()
  {
    if (showColors) std::cout << "\033[0;33m";
  }

  void Runner::clear()
  {
    if (showColors) std::cout << "\033[m";
  }

  void Runner::specPassed()
  {
    consoleNotUsedThisRun = true;
    green();
    std::cout << '.';
    clear();
    fflush(stdout);
  }

  void Runner::specFailed(const QString &specDetail)
  {
    consoleNotUsedThisRun = true;
    didFail = true;
    red();
    std::cout << 'F';
    failedSpecs.push(specDetail);
    clear();
    fflush(stdout);
  }

  void Runner::errorLog(const QString &msg, int lineNumber, const QString &sourceID)
  {
    red();
    std::cout << "[error] ";
    clear();
    std::cout << qPrintable(sourceID) << ":" << lineNumber << " : " << qPrintable(msg);
    std::cout << std::endl;

    hasErrors = true;
    m_runs = 0;
    m_ticker.start(200, this);
  }

  void Runner::internalLog(const QString &note, const QString &msg) {
    red();
    std::cout << "[" << qPrintable(note) << "] ";
    clear();
    std::cout << qPrintable(msg);
    std::cout << std::endl;
  }

  void Runner::log(const QString &msg)
  {
    usedConsole = true;
    green();
    if (consoleNotUsedThisRun) {
      std::cout << std::endl;
      consoleNotUsedThisRun = false;
    }
    std::cout << "[console] ";
    clear();
    if (msg.contains("\n"))
      std::cout << std::endl;
    std::cout << qPrintable(msg);
    std::cout << std::endl;
  }

  void Runner::leavePageAttempt(const QString &msg)
  {
    red();
    std::cout << "[error] ";
    clear();
    std::cout << qPrintable(msg) << std::endl;
    m_page.oneFalseConfirm();
    hasErrors = true;
  }

  void Runner::printName(const QString &name)
  {
    std::cout << std::endl << std::endl;
    red();
    std::cout << qPrintable(name) << std::endl;
    clear();
  }

  void Runner::printResult(const QString &result)
  {
    red();
    std::cout << "  " << qPrintable(result) << std::endl;
    clear();
  }

  void Runner::finishSuite(const QString &duration, const QString &total, const QString& failed)
  {
    std::cout << std::endl;
    if (didFail) {
      red();
      std::cout << "FAIL: ";
    } else {
      green();
      std::cout << "PASS";

      if (hasErrors) {
        std::cout << " with JS errors";
      }

      std::cout << ": ";
    }

    std::cout << qPrintable(total) << " tests, " << qPrintable(failed) << " failures, " << qPrintable(duration) << " secs.";
    clear();
    std::cout << std::endl;

    if (!reportFilename.isEmpty()) {
      QFile reportFH(reportFilename);

      if (reportFH.open(QFile::WriteOnly)) {
        QTextStream report(&reportFH);
        report << qPrintable(total) << "/" << qPrintable(failed) << "/";
        report << (usedConsole ? "T" : "F");
        report << "/" << qPrintable(duration) << "\n";

        QString failedSpec;

        while (!failedSpecs.isEmpty()) {
          failedSpec = failedSpecs.pop();
          report << qPrintable(failedSpec) << "\n";
        }

        reportFH.close();
      }
    }

    isFinished = true;
  }

  void Runner::timerEvent(QTimerEvent *event)
  {
    ++m_runs;

    if (event->timerId() != m_ticker.timerId())
      return;

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

    if (m_runs > 30) {
      std::cout << "WARNING: too many runs and the test is still not finished!" << std::endl;
      QApplication::instance()->exit(1);
    }
  }
}

