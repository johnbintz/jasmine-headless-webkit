if window.JHW
  window.console =
    log: (data) ->
      if typeof(jQuery) != 'undefined' && data instanceof jQuery
        JHW.log(style_html($("<div />").append(data).html(), { indent_size: 2 }))
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
    JHW.leavePageAttempt()

    JHW.stderr.puts('The code tried to leave the test page. Check for unhandled form submits and link clicks.')

    if e = e || window.event
      e.returnValue = "leaving"

    return "leaving"

  window.confirm = (message) ->
    JHW.stderr.puts("jasmine-headless-webkit can't handle confirm() yet! You should mock window.confirm. Returning true.")
    true

  window.alert = (message) ->
    JHW.stderr.puts(message)

  JHW.error = (message, sourceUrl, lineNumber) ->


  for handle in [ 'stdout', 'stderr', 'report' ]
    JHW[handle] =
      print: (content) -> JHW.print(handle, content)
      puts: (content) -> JHW.print(handle, content + "\n")

  JHW.log = (msg) ->
    JHW.usedConsole()
    JHW.stdout.puts(msg)

