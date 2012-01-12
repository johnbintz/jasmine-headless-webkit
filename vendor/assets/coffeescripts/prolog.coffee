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

  puts = (message) ->
    JHW.print('stdout', message + "\n")

  warn = (message) ->
    puts(message) if !JHW.isQuiet()

  # handle unloading
  window.onbeforeunload = (e) ->
    e = e || window.event

    JHW.hasError()
    warn "The code tried to leave the test page. Check for unhandled form submits and link clicks."

    e.returnValue = 'string' if e

    return 'string'

  # script errors
  JHW._hasErrors = false
  JHW._handleError = (message, lineNumber, sourceURL) ->
    JHW.print('stderr', message + "\n")
    JHW._hasErrors = true
    false

  # dialogs
  window.confirm = ->
    warn "#{"[confirm]".foreground('red')} You should mock window.confirm. Returning true."

    true

  window.prompt =  ->
    warn "#{"[prompt]".foreground('red')} You should mock window.prompt. Returning true."

    true

  window.alert = (message) ->
    warn "[alert] ".foreground('red') + message

  # color support
  JHW._setColors = (useColors) -> Intense.useColors = useColors

  # console.log support
  JHW._usedConsole = false
  JHW.log = (msg) ->
    JHW.hasUsedConsole()

    for reporter in jasmine.getEnv().reporter.subReporters_
      reporter.consoleLogUsed(msg) if reporter.consoleLogUsed?

    JHW._usedConsole = true

    puts msg

  JHW.createCoffeeScriptFileException = (e) ->
    if e and e.sourceURL
      filename = e.sourceURL.split('/').pop()

      e =
        name: e.name
        message: e.message
        sourceURL: e.sourceURL
        lineNumber: e.line

      if window.CoffeeScriptToFilename and realFilename = window.CoffeeScriptToFilename[filename]
        e.sourceURL = realFilename
        e.lineNumber = "~" + String(e.line)

    e

window.CoffeeScriptToFilename = {}
window.CSTF = window.CoffeeScriptToFilename

