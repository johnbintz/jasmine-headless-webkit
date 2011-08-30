#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <QQueue>

#include "Runner.h"

  Runner::Runner() : QObject()
    , m_runs(0)
    , hasErrors(false)
    , usedConsole(false)
    , isFinished(false)
    , didFail(false) {
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
    consoleOutput.showColors = colors;
  }

  void Runner::reportFile(const QString &file)
  {
    reportFilename = file;
  }

  bool Runner::hasError() {
    return hasErrors;
  }

  void Runner::specPassed()
  {
    consoleOutput.passed("");
  }

  void Runner::specFailed(const QString &specDetail)
  {
    consoleOutput.failed("");
    didFail = true;
    failedSpecs.push(specDetail);
  }

  void Runner::errorLog(const QString &msg, int lineNumber, const QString &sourceID)
  {
    consoleOutput.errorLog(msg, lineNumber, sourceID);

    hasErrors = true;
    m_runs = 0;
    m_ticker.start(200, this);
  }

  void Runner::internalLog(const QString &note, const QString &msg) {
    consoleOutput.internalLog(note, msg);
  }

  void Runner::log(const QString &msg)
  {
    usedConsole = true;
    consoleOutput.consoleLog(msg);
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
    } else {
      if (hasErrors) {
        consoleOutput.reportSuccessWithJSErrors(total, failed, duration);
      } else {
        consoleOutput.reportSuccess(total, failed, duration);
      }
    }

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

