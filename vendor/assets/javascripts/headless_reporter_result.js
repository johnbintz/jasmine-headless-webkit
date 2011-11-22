
  window.HeadlessReporterResult = (function() {

    function HeadlessReporterResult(name, splitName) {
      this.name = name;
      this.splitName = splitName;
      this.results = [];
    }

    HeadlessReporterResult.prototype.addResult = function(message) {
      return this.results.push(message);
    };

    HeadlessReporterResult.prototype.print = function() {
      var bestChoice, output, result, _i, _len, _ref, _results;
      output = this.name.foreground('red');
      bestChoice = HeadlessReporterResult.findSpecLine(this.splitName);
      if (bestChoice.file) {
        output += (" (" + bestChoice.file + ":" + bestChoice.lineNumber + ")").foreground('blue');
      }
      JHW.stdout.puts("\n" + output);
      _ref = this.results;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        result = _ref[_i];
        output = result.message.foreground('red');
        if (result.lineNumber) {
          output += (" (line ~" + (bestChoice.lineNumber + result.lineNumber) + ")").foreground('red').bright();
        }
        JHW.stdout.puts("  " + output);
        if (result.line != null) {
          _results.push(JHW.stdout.puts(("    " + result.line).foreground('yellow')));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    HeadlessReporterResult.findSpecLine = function(splitName) {
      var bestChoice, file, index, lastLine, line, lineNumber, lines, newLineNumberInfo, _i, _len, _ref;
      bestChoice = {
        accuracy: 0,
        file: null,
        lineNumber: null
      };
      _ref = HeadlessReporterResult.specLineNumbers;
      for (file in _ref) {
        lines = _ref[file];
        index = 0;
        lineNumber = 0;
        while (newLineNumberInfo = lines[splitName[index]]) {
          if (newLineNumberInfo.length === 0) {
            lineNumber = newLineNumberInfo[0];
          } else {
            lastLine = null;
            for (_i = 0, _len = newLineNumberInfo.length; _i < _len; _i++) {
              line = newLineNumberInfo[_i];
              lastLine = line;
              if (line > lineNumber) break;
            }
            lineNumber = lastLine;
          }
          index++;
        }
        if (index > bestChoice.accuracy) {
          bestChoice = {
            accuracy: index,
            file: file,
            lineNumber: lineNumber
          };
        }
      }
      return bestChoice;
    };

    return HeadlessReporterResult;

  })();
