#include "Test/Page_test.h"
#include <QTest>

QTEST_MAIN
int main(int argc, char *argv[]) {
    QCoreApplication app(argc, argv);
    HeadlessSpecRunner::PageTest pageTest;
    QTest::qExec(&pageTest);
}

