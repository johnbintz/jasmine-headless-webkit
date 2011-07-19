/*
 Copyright (c) 2010 Sencha Inc.
 Copyright (c) 2011 John Bintz

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#include <QtGui>
#include <QtWebKit>
#include <QFile>
#include <QTextStream>
#include <iostream>
#include <QQueue>

#if QT_VERSION < QT_VERSION_CHECK(4, 7, 0)
#error Use Qt 4.7 or later version
#endif

class HeadlessSpecRunnerPage: public QWebPage
{
  Q_OBJECT
signals:
  void consoleLog(const QString &msg, int lineNumber, const QString &sourceID);
  void internalLog(const QString &note, const QString &msg);
protected:
  void javaScriptConsoleMessage(const QString & message, int lineNumber, const QString & sourceID);
  bool javaScriptConfirm(QWebFrame *frame, const QString &msg);
  void javaScriptAlert(QWebFrame *frame, const QString &msg);
};

void HeadlessSpecRunnerPage::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID)
{
  emit consoleLog(message, lineNumber, sourceID);
}

bool HeadlessSpecRunnerPage::javaScriptConfirm(QWebFrame *frame, const QString &msg)
{
  emit internalLog("TODO", "jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm for now. Returning true."); 
  return true;
}

void HeadlessSpecRunnerPage::javaScriptAlert(QWebFrame *frame, const QString &msg)
{
  emit internalLog("alert", msg);
}

class HeadlessSpecRunner: public QObject
{
    Q_OBJECT
public:
    HeadlessSpecRunner();
    void setColors(bool colors);
    void reportFile(const QString &file);
    void addFile(const QString &spec);
    void go();
public slots:
    void log(const QString &msg);
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
    HeadlessSpecRunnerPage m_page;
    QBasicTimer m_ticker;
    int m_runs;
    bool hasErrors;
    bool usedConsole;
    bool showColors;
    bool isFinished;
    bool didFail;
    bool consoleNotUsedThisRun;
    QQueue<QString> runnerFiles;
    QString reportFilename;
    QStack<QString> failedSpecs;
    
    void red();
    void green();
    void yellow();
    void clear();
    void loadSpec();
};

HeadlessSpecRunner::HeadlessSpecRunner()
    : QObject()
    , m_runs(0)
    , hasErrors(false)
    , usedConsole(false)
    , showColors(false)
    , isFinished(false)
    , didFail(false)
    , consoleNotUsedThisRun(false)
{
    m_page.settings()->enablePersistentStorage();
    connect(&m_page, SIGNAL(loadFinished(bool)), this, SLOT(watch(bool)));
    connect(&m_page, SIGNAL(consoleLog(QString, int, QString)), this, SLOT(errorLog(QString, int, QString)));
    connect(&m_page, SIGNAL(internalLog(QString, QString)), this, SLOT(internalLog(QString, QString)));
    connect(m_page.mainFrame(), SIGNAL(javaScriptWindowObjectCleared()), this, SLOT(addJHW()));
}

void HeadlessSpecRunner::addFile(const QString &spec)
{
  runnerFiles.enqueue(spec);
}

void HeadlessSpecRunner::go()
{
    m_ticker.stop();
    m_page.setPreferredContentsSize(QSize(1024, 600));
    addJHW();
    loadSpec();
}
void HeadlessSpecRunner::addJHW()
{
    m_page.mainFrame()->addToJavaScriptWindowObject("JHW", this);
}

void HeadlessSpecRunner::loadSpec()
{
    m_page.mainFrame()->load(runnerFiles.dequeue());
    m_ticker.start(200, this);
}

void HeadlessSpecRunner::watch(bool ok)
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

bool HeadlessSpecRunner::hasElement(const char *select)
{
    return !m_page.mainFrame()->findFirstElement(select).isNull();
}

void HeadlessSpecRunner::setColors(bool colors)
{
    showColors = colors;
}

void HeadlessSpecRunner::reportFile(const QString &file)
{
    reportFilename = file;
}

void HeadlessSpecRunner::red()
{
  if (showColors) std::cout << "\033[0;31m";
}

void HeadlessSpecRunner::green()
{
  if (showColors) std::cout << "\033[0;32m";
}

void HeadlessSpecRunner::yellow()
{
  if (showColors) std::cout << "\033[0;33m";
}

void HeadlessSpecRunner::clear()
{
  if (showColors) std::cout << "\033[m";
}

void HeadlessSpecRunner::specPassed()
{
  consoleNotUsedThisRun = true;
  green();
  std::cout << '.';
  clear();
  fflush(stdout);
}

void HeadlessSpecRunner::specFailed(const QString &specDetail)
{
  consoleNotUsedThisRun = true;
  didFail = true;
  red();
  std::cout << 'F';
  failedSpecs.push(specDetail);
  clear();
  fflush(stdout);
}

void HeadlessSpecRunner::errorLog(const QString &msg, int lineNumber, const QString &sourceID)
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

void HeadlessSpecRunner::internalLog(const QString &note, const QString &msg) {
  red();
  std::cout << "[" << qPrintable(note) << "] ";
  clear();
  std::cout << qPrintable(msg);
  std::cout << std::endl;
}

void HeadlessSpecRunner::log(const QString &msg)
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

void HeadlessSpecRunner::printName(const QString &name)
{
  std::cout << std::endl << std::endl;
  red();
  std::cout << qPrintable(name) << std::endl;
  clear();
}

void HeadlessSpecRunner::printResult(const QString &result)
{
  red();
  std::cout << "  " << qPrintable(result) << std::endl;
  clear();
}

void HeadlessSpecRunner::finishSuite(const QString &duration, const QString &total, const QString& failed)
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

void HeadlessSpecRunner::timerEvent(QTimerEvent *event)
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

#include "specrunner.moc"

int main(int argc, char** argv)
{
    char *reporter = NULL;
    char showColors = false;

    int c, index;

    while ((c = getopt(argc, argv, "cr:")) != -1) {
      switch(c) {
        case 'c':
          showColors = true;
          break;
        case 'r':
          reporter = optarg;
          break;
      }
    }

    if (optind == argc) {
        std::cerr << "Run Jasmine's SpecRunner headlessly" << std::endl << std::endl;
        std::cerr << "  specrunner [-c] [-r <report file>] specrunner.html ..." << std::endl;
        return 1;
    }

    QApplication app(argc, argv);
    app.setApplicationName("jasmine-headless-webkit");
    HeadlessSpecRunner runner;
    runner.setColors(showColors);
    runner.reportFile(reporter);

    for (index = optind; index < argc; index++) {
      runner.addFile(QString::fromLocal8Bit(argv[index]));
    }
    runner.go();

    return app.exec();
}


