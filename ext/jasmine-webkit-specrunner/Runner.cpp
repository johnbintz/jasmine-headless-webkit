#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <sstream>
#include <QQueue>

#include "Runner.h"
#include "Page.h"

using namespace std;

Runner::Runner() : QObject()
  , m_runs(0)
  , hasErrors(false)
  , usedConsole(false)
  , isFinished(false)
  , didFail(false)
  , useColors(false)
  {
  m_page.settings()->enablePersistentStorage();
  m_ticker.setInterval(TIMER_TICK);

  connect(&m_ticker, SIGNAL(timeout()), this, SLOT(timerEvent()));
  connect(&m_page, SIGNAL(loadFinished(bool)), this, SLOT(watch(bool)));
  connect(&m_page, SIGNAL(handleError(const QString &, int, const QString &)), this, SLOT(handleError(const QString &, int, const QString &)));
  connect(m_page.mainFrame(), SIGNAL(javaScriptWindowObjectCleared()), this, SLOT(addJHW()));
}

void Runner::addFile(const QString &spec) {
  runnerFiles.enqueue(spec);
}

void Runner::go() {
  m_ticker.stop();
  m_page.setPreferredContentsSize(QSize(1024, 600));
  addJHW();

  loadSpec();
}
void Runner::addJHW() {
  m_page.mainFrame()->addToJavaScriptWindowObject("JHW", this);
}

void Runner::handleError(const QString &message, int lineNumber, const QString &sourceID) {
  QString messageEscaped = QString(message);
  QString sourceIDEscaped = QString(sourceID);

  messageEscaped.replace(QString("\""), QString("\\\""));
  sourceIDEscaped.replace(QString("\""), QString("\\\""));

  std::stringstream ss;
  ss << lineNumber;

  QString command("JHW._handleError(\"" + messageEscaped + "\", " + QString(ss.str().c_str()) + ", \"" + sourceIDEscaped + "\"); false;");

  m_page.mainFrame()->evaluateJavaScript(command);

  hasErrors = true;
}

void Runner::loadSpec()
{
  if (reportFileName.isEmpty()) {
    outputFile = 0;
    ts = 0;
  } else {
    outputFile = new QFile(reportFileName);
    outputFile->open(QIODevice::WriteOnly);

    ts = new QTextStream(outputFile);
  }

  m_page.mainFrame()->load(runnerFiles.dequeue());
  m_ticker.start();
}

void Runner::watch(bool ok) {
  if (!ok) {
    std::cerr << "Can't load " << qPrintable(m_page.mainFrame()->url().toString()) << ", the file may be broken." << std::endl;
    std::cerr << "Out of curiosity, did your tests try to submit a form and you haven't prevented that?" << std::endl;
    std::cerr << "Try running your tests in your browser with the Jasmine server and see what happens." << std::endl;
    QApplication::instance()->exit(1);
    return;
  }

  m_page.mainFrame()->evaluateJavaScript(QString("JHW._setColors(") + (useColors ? QString("true") : QString("false")) + QString("); false;"));
}

void Runner::setColors(bool colors) {
  useColors = colors;
}

void Runner::hasUsedConsole() {
  usedConsole = true;
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

  if (fh == "report" && outputFile) {
    *ts << qPrintable(content);
    ts->flush();
  }
}

void Runner::finishSuite() {
  isFinished = true;
}

void Runner::timerEvent() {
  ++m_runs;

  if (hasErrors && m_runs > 2)
    QApplication::instance()->exit(1);

  if (isFinished) {
    if (outputFile) {
      outputFile->close();
    }

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

