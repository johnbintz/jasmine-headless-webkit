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

  # handle unloading
  window.onbeforeunload = (e) ->
    e = e || window.event

    JHW.hasError()
    puts "The code tried to leave the test page. Check for unhandled form submits and link clicks."

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
    puts "#{"[confirm]".foreground('red')} You should mock window.confirm. Returning true."

    true

  window.prompt =  ->
    puts "#{"[prompt]".foreground('red')} You should mock window.prompt. Returning true."

    true

  window.alert = (message) ->
    puts "[alert] ".foreground('red') + message

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

window.CoffeeScriptToFilename = {}
window.CSTF = window.CoffeeScriptToFilename

