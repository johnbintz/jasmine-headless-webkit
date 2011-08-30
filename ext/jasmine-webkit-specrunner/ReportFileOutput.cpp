#include "ReportFileOutput.h"

ReportFileOutput::ReportFileOutput() : QObject() {

}

void ReportFileOutput::passed(const QString &specDetail) {
  *outputIO << "PASS||" << qPrintable(specDetail) << std::endl;
  successes.push(specDetail);
}
