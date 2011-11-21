(function() {
  var createHandle, handle, _i, _len, _ref;

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
      JHW.stdout.puts('The code tried to leave the test page. Check for unhandled form submits and link clicks.');
      if (e) e.returnValue = 'string';
      return 'string';
    };
    window.confirm = function(message) {
      JHW.stderr.puts("" + ("[confirm]".foreground('red')) + " jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm. Returning true.");
      return true;
    };
    window.alert = function(message) {
      return JHW.stderr.puts("[alert] ".foreground('red') + message);
    };
    JHW._hasErrors = false;
    JHW._handleError = function(message, lineNumber, sourceURL) {
      JHW.stderr.puts(message);
      JHW._hasErrors = true;
      return false;
    };
    JHW._setColors = function(useColors) {
      return Intense.useColors = useColors;
    };
    createHandle = function(handle) {
      return JHW[handle] = {
        print: function(content) {
          return JHW.print(handle, content);
        },
        puts: function(content) {
          return JHW.print(handle, content + "\n");
        }
      };
    };
    _ref = ['stdout', 'stderr', 'report'];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      handle = _ref[_i];
      createHandle(handle);
    }
    JHW._usedConsole = false;
    JHW.log = function(msg) {
      JHW.hasUsedConsole();
      JHW.report.puts("CONSOLE||" + msg);
      JHW._usedConsole = true;
      return JHW.stdout.puts(msg);
    };
  }

  window.CoffeeScriptToFilename = {};

  window.CSTF = window.CoffeeScriptToFilename;

}).call(this);
