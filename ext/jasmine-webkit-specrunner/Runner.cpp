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
  , runs(0)
  , hasErrors(false)
  , _hasSpecFailure(false)
  , usedConsole(false)
  , isFinished(false)
  , useColors(false)
  {
  page.settings()->enablePersistentStorage();
  ticker.setInterval(TIMER_TICK);

  connect(&ticker, SIGNAL(timeout()), this, SLOT(timerEvent()));
  connect(&page, SIGNAL(loadFinished(bool)), this, SLOT(watch(bool)));
  connect(&page, SIGNAL(handleError(const QString &, int, const QString &)), this, SLOT(handleError(const QString &, int, const QString &)));
  connect(page.mainFrame(), SIGNAL(javaScriptWindowObjectCleared()), this, SLOT(addJHW()));
}

void Runner::addFile(const QString &spec) {
  runnerFiles.enqueue(spec);
}

void Runner::go() {
  ticker.stop();
  page.setPreferredContentsSize(QSize(1024, 600));
  addJHW();

  loadSpec();
}
void Runner::addJHW() {
  page.mainFrame()->addToJavaScriptWindowObject("JHW", this);
}

void Runner::handleError(const QString &message, int lineNumber, const QString &sourceID) {
  QString messageEscaped = QString(message);
  QString sourceIDEscaped = QString(sourceID);

  messageEscaped.replace(QString("\""), QString("\\\""));
  sourceIDEscaped.replace(QString("\""), QString("\\\""));

  std::stringstream ss;
  ss << lineNumber;

  QString command("JHW._handleError(\"" + messageEscaped + "\", " + QString(ss.str().c_str()) + ", \"" + sourceIDEscaped + "\"); false;");

  page.mainFrame()->evaluateJavaScript(command);

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

  page.mainFrame()->load(runnerFiles.dequeue());
  ticker.start();
}

void Runner::watch(bool ok) {
  if (!ok) {
    std::cerr << "Can't load " << qPrintable(page.mainFrame()->url().toString()) << ", the file may be broken." << std::endl;
    std::cerr << "Out of curiosity, did your tests try to submit a form and you haven't prevented that?" << std::endl;
    std::cerr << "Try running your tests in your browser with the Jasmine server and see what happens." << std::endl;
    QApplication::instance()->exit(1);
    return;
  }

  page.mainFrame()->evaluateJavaScript(QString("JHW._setColors(") + (useColors ? QString("true") : QString("false")) + QString("); false;"));
}

void Runner::setColors(bool colors) {
  useColors = colors;
}

void Runner::hasUsedConsole() {
  usedConsole = true;
}

void Runner::hasError() {
  hasErrors = true;
}

void Runner::hasSpecFailure() {
  _hasSpecFailure = true;
}

void Runner::reportFile(const QString &file) {
  reportFileName = file;
}

void Runner::timerPause() {
  ticker.stop();
}

void Runner::timerDone() {
  ticker.start();
}

void Runner::ping() {
  runs = 0;
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
  ++runs;

  if (hasErrors && runs > 2)
    QApplication::instance()->exit(1);

  if (isFinished) {
    if (outputFile) {
      outputFile->close();
    }

    int exitCode = 0;
    if (_hasSpecFailure || hasErrors) {
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

  if (runs > MAX_LOOPS) {
    std::cerr << "WARNING: too many runs and the test is still not finished!" << std::endl;
    QApplication::instance()->exit(1);
  }
}

