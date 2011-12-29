if window.JHW
  window.console =
    log: (data) ->
      if typeof(jQuery) != 'undefined' && data instanceof jQuery
        JHW.log(style_html($("<div />").append(data.clone()).html(), { indent_size: 2 }))
      else
        useJsDump = true

        try
          if typeof data.toJSON == 'function'
            JHW.log("JSON: #{JSON.stringify(data, null, 2)}")
            useJsDump = false
        catch e

        if useJsDump
          dump = jsDump.doParse(data)
          if dump.indexOf("\n") == -1
            JHW.log(dump)
          else
            JHW.log("jsDump: #{dump}")

    pp: (data) ->
      JHW.log(if jasmine then jasmine.pp(data) else console.log(data))

    peek: (data) ->
      console.log(data)
      data

  window.onbeforeunload = (e) ->
    e = e || window.event

    JHW.hasError()
    JHW.print('stdout', "The code tried to leave the test page. Check for unhandled form submits and link clicks.\n")

    if e
      e.returnValue = 'string'

    return 'string'

  window.confirm = (message) ->
    JHW.print('stdout', "#{"[confirm]".foreground('red')} jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm. Returning true.\n")
    true

  window.alert = (message) ->
    JHW.print('stdout', "[alert] ".foreground('red') + message + "\n")

  JHW._hasErrors = false
  JHW._handleError = (message, lineNumber, sourceURL) ->
    JHW.print('stderr', message + "\n")
    JHW._hasErrors = true
    false

  JHW._setColors = (useColors) ->
    Intense.useColors = useColors

  JHW._usedConsole = false

  JHW.log = (msg) ->
    JHW.hasUsedConsole()

    for reporter in jasmine.getEnv().reporter.subReporters_
      reporter.consoleLogUsed(msg) if reporter.consoleLogUsed?

    JHW._usedConsole = true
    JHW.print('stdout', msg + "\n")

window.CoffeeScriptToFilename = {}
window.CSTF = window.CoffeeScriptToFilename

