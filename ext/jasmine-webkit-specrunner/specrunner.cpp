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

#include "Runner.h"

#if QT_VERSION < QT_VERSION_CHECK(4, 7, 0)
#error Use Qt 4.7 or later version
#endif

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
  Runner runner;
  runner.setColors(showColors);

  runner.reportFile(reporter);

  for (index = optind; index < argc; index++) {
    runner.addFile(QString::fromLocal8Bit(argv[index]));
  }

  runner.go();

  return app.exec();
}

