
  if (window.JHW) {
    window.console = {
      log: function(data) {
        var dump, useJsDump;
        if (typeof jQuery !== 'undefined' && data instanceof jQuery) {
          return JHW.log(style_html($("<div />").append(data.clone()).html(), {
            indent_size: 2
          }));
        } else {
          useJsDump = true;
          try {
            if (typeof data.toJSON === 'function') {
              JHW.log("JSON: " + (JSON.stringify(data, null, 2)));
              useJsDump = false;
            }
          } catch (e) {

          }
          if (useJsDump) {
            dump = jsDump.doParse(data);
            if (dump.indexOf("\n") === -1) {
              return JHW.log(dump);
            } else {
              return JHW.log("jsDump: " + dump);
            }
          }
        }
      },
      pp: function(data) {
        return JHW.log(jasmine ? jasmine.pp(data) : console.log(data));
      },
      peek: function(data) {
        console.log(data);
        return data;
      }
    };
    window.onbeforeunload = function(e) {
      e = e || window.event;
      JHW.hasError();
      JHW.print('stdout', "The code tried to leave the test page. Check for unhandled form submits and link clicks.\n");
      if (e) e.returnValue = 'string';
      return 'string';
    };
    window.confirm = function(message) {
      JHW.print('stdout', "" + ("[confirm]".foreground('red')) + " jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm. Returning true.\n");
      return true;
    };
    window.alert = function(message) {
      return JHW.print('stdout', "[alert] ".foreground('red') + message + "\n");
    };
    JHW._hasErrors = false;
    JHW._handleError = function(message, lineNumber, sourceURL) {
      JHW.print('stderr', message + "\n");
      JHW._hasErrors = true;
      return false;
    };
    JHW._setColors = function(useColors) {
      return Intense.useColors = useColors;
    };
    JHW._usedConsole = false;
    JHW.log = function(msg) {
      var reporter, _i, _len, _ref;
      JHW.hasUsedConsole();
      _ref = jasmine.getEnv().reporter.subReporters_;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        reporter = _ref[_i];
        if (reporter.consoleLogUsed != null) reporter.consoleLogUsed(msg);
      }
      JHW._usedConsole = true;
      return JHW.print('stdout', msg + "\n");
    };
  }

  window.CoffeeScriptToFilename = {};

  window.CSTF = window.CoffeeScriptToFilename;
