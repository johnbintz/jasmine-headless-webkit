#ifndef JHW_PAGE
#define JHW_PAGE

#include <QtGui>
#include <QtWebKit>

namespace HeadlessSpecRunner {
  class Page: public QWebPage {
    Q_OBJECT
    public:
      Page();
      void oneFalseConfirm();
    signals:
      void consoleLog(const QString &msg, int lineNumber, const QString &sourceID);
      void internalLog(const QString &note, const QString &msg);
    protected:
      void javaScriptConsoleMessage(const QString & message, int lineNumber, const QString & sourceID);
      bool javaScriptConfirm(QWebFrame *frame, const QString &msg);
      void javaScriptAlert(QWebFrame *frame, const QString &msg);
    private:
      bool confirmResult;
  };
}

#endif
