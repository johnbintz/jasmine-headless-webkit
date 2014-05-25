#ifndef JHW_PAGE
#define JHW_PAGE

#include <QtGui>
#if QT_VERSION >= QT_VERSION_CHECK(5, 0, 0)
  #include <QtWebKitWidgets>
#else
  #include <QtWebKit>
#endif

class Page: public QWebPage {
  Q_OBJECT
  public:
    Page();
  protected:
    void javaScriptConsoleMessage(const QString & message, int lineNumber, const QString & sourceID);
    void javaScriptAlert(QWebFrame *, const QString &);
    bool javaScriptConfirm(QWebFrame *, const QString &);
    bool javaScriptPrompt(QWebFrame *, const QString &, const QString &, QString *);
  signals:
    void handleError(const QString & message, int lineNumber, const QString & sourceID);
};

#endif
