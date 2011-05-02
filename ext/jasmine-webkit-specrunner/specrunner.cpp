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
#include <iostream>

#if QT_VERSION < QT_VERSION_CHECK(4, 7, 0)
#error Use Qt 4.7 or later version
#endif

class HeadlessSpecRunnerPage: public QWebPage
{
  Q_OBJECT
signals:
  void consoleLog(const QString &msg, int lineNumber, const QString &sourceID);
protected:
  void javaScriptConsoleMessage(const QString & message, int lineNumber, const QString & sourceID);
};

void HeadlessSpecRunnerPage::javaScriptConsoleMessage(const QString &message, int lineNumber, const QString &sourceID)
{
  emit consoleLog(message, lineNumber, sourceID);
}

class HeadlessSpecRunner: public QObject
{
    Q_OBJECT
public:
    HeadlessSpecRunner();
    void load(const QString &spec);
    void setColors(bool colors);
public slots:
    void log(const QString &msg);
    void specLog(int indent, const QString &msg, const QString &clazz);
private slots:
    void watch(bool ok);
    void errorLog(const QString &msg, int lineNumber, const QString &sourceID);
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
    
    void red();
    void green();
    void yellow();
    void clear();
};

HeadlessSpecRunner::HeadlessSpecRunner()
    : QObject()
    , m_runs(0)
    , hasErrors(false)
    , usedConsole(false)
    , showColors(false)
{
    m_page.settings()->enablePersistentStorage();
    connect(&m_page, SIGNAL(loadFinished(bool)), this, SLOT(watch(bool)));
    connect(&m_page, SIGNAL(consoleLog(QString, int, QString)), this, SLOT(errorLog(QString, int, QString)));
}

void HeadlessSpecRunner::load(const QString &spec)
{
    m_ticker.stop();
    m_page.mainFrame()->addToJavaScriptWindowObject("debug", this);
    m_page.mainFrame()->load(spec);
    m_page.setPreferredContentsSize(QSize(1024, 600));
}

void HeadlessSpecRunner::watch(bool ok)
{
    if (!ok) {
        std::cerr << "Can't load' " << qPrintable(m_page.mainFrame()->url().toString()) << std::endl;
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

void HeadlessSpecRunner::log(const QString &msg)
{
  usedConsole = true;
  green();
  std::cout << "[console] ";
  clear();
  std::cout << qPrintable(msg);
  std::cout << std::endl;
}

void HeadlessSpecRunner::specLog(int indent, const QString &msg, const QString &clazz)
{
    for (int i = 0; i < indent; ++i)
        std::cout << "  ";
    if ( clazz.endsWith("fail") ) {
        red();
    } else {
        yellow();
    }
    std::cout << qPrintable(msg);
    clear();
    std::cout << std::endl;
}

#define DUMP_MSG "(function(n, i) { \
  if (n.toString() === '[object NodeList]') { \
    for (var c = 0; c < n.length; ++c) arguments.callee(n[c], i); return \
  }\
  if (n.className === 'description' || n.className == 'resultMessage fail') {\
    debug.specLog(i, n.textContent, n.className);\
  }\
  var e = n.firstElementChild;\
  while (e) {\
    arguments.callee(e, i + 1); e = e.nextElementSibling; \
  }\
  n.className = '';\
})(document.getElementsByClassName('suite failed'), 0);"

void HeadlessSpecRunner::timerEvent(QTimerEvent *event)
{
    ++m_runs;

    if (event->timerId() != m_ticker.timerId())
        return;

    if (hasErrors && m_runs > 2)
        QApplication::instance()->exit(1);

    if (!hasErrors) {
      if (!hasElement(".jasmine_reporter") && !hasElement(".runner.running"))
          return;

      if (hasElement(".runner.passed")) {
          QWebElement desc = m_page.mainFrame()->findFirstElement(".description");
          green();
          std::cout << "PASS: " << qPrintable(desc.toPlainText());
          clear();
          std::cout << std::endl;
          QApplication::instance()->exit(usedConsole ? 2 : 0);
          return;
      }

      if (hasElement(".runner.failed")) {
          QWebElement desc = m_page.mainFrame()->findFirstElement(".description");
          red();
          std::cout << "FAIL: " << qPrintable(desc.toPlainText());
          clear();
          std::cout << std::endl;
          m_page.mainFrame()->evaluateJavaScript(DUMP_MSG);
          QApplication::instance()->exit(1);
          return;
      }

      if (m_runs > 30) {
          std::cout << "WARNING: too many runs and the test is still not finished!" << std::endl;
          QApplication::instance()->exit(1);
      }
    }
}

#include "specrunner.moc"

int main(int argc, char** argv)
{
    bool showColors = false;
    char *filename = NULL;

    int c, index;

    while ((c = getopt(argc, argv, "c")) != -1) {
      switch(c) {
        case 'c':
          showColors = true;
          break;
      }
    }

    bool filenameFound = false;

    for (index = optind; index < argc; index++) {
      filename = argv[index];
      filenameFound = true;
    }

    if (!filenameFound) {
        std::cerr << "Run Jasmine's SpecRunner headlessly" << std::endl << std::endl;
        std::cerr << "  specrunner [-c] SpecRunner.html" << std::endl;
        return 1;
    }

    QApplication app(argc, argv);

    HeadlessSpecRunner runner;
    runner.setColors(showColors);
    runner.load(QString::fromLocal8Bit(filename));
    return app.exec();
}

